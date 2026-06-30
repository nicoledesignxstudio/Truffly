import type { SupabaseClient } from "@supabase/supabase-js";

import {
  buildItalianPushContent,
  buildNotificationEnvelope,
  buildPushData,
  isHighImportanceNotification,
  type NotificationMetadata,
} from "./notification_catalog.ts";
import {
  type FirebasePushConfig,
  type FirebasePushResult,
  sendFirebasePushToUser,
} from "./firebase_messaging.ts";

type CreateBusinessNotificationArgs = {
  adminClient: SupabaseClient;
  userId: string;
  type: string;
  message?: string;
  title?: string;
  metadata?: NotificationMetadata;
  targetRoute?: string;
  targetId?: string;
  data?: Record<string, string>;
  requestId: string;
  pushConfig?: FirebasePushConfig;
};

export async function createBusinessNotificationAndPush(
  args: CreateBusinessNotificationArgs,
): Promise<void> {
  const envelope = buildNotificationEnvelope({
    type: args.type,
    metadata: args.metadata,
    message: args.message,
    targetRoute: args.targetRoute,
    targetId: args.targetId,
  });
  const insertResult = await args.adminClient
    .from("notifications")
    .insert({
      user_id: args.userId,
      type: envelope.type,
      message: envelope.message,
      target_route: envelope.targetRoute,
      target_id: envelope.targetId,
      metadata: envelope.metadata,
    })
    .select("id,type,target_route,target_id,metadata")
    .single();

  if (insertResult.error || !insertResult.data?.id) {
    console.error("business notification insert failed", {
      request_id: args.requestId,
      code: readErrorCode(insertResult.error),
      message: readErrorMessage(insertResult.error),
    });
    return;
  }

  const notificationId = String(insertResult.data.id);
  const persistedMetadata = isRecord(insertResult.data.metadata)
    ? insertResult.data.metadata
    : envelope.metadata;
  const persistedTargetRoute =
    typeof insertResult.data.target_route === "string"
      ? insertResult.data.target_route
      : envelope.targetRoute;
  const persistedTargetId = typeof insertResult.data.target_id === "string"
    ? insertResult.data.target_id
    : envelope.targetId;
  const persistedType = typeof insertResult.data.type === "string"
    ? insertResult.data.type
    : envelope.type;

  await claimOutboxForImmediateSend(args.adminClient, notificationId);
  const result = await sendNotificationPush({
    adminClient: args.adminClient,
    notificationId,
    userId: args.userId,
    type: persistedType,
    metadata: persistedMetadata,
    targetRoute: persistedTargetRoute,
    targetId: persistedTargetId,
    title: args.title,
    data: args.data,
    requestId: args.requestId,
    pushConfig: args.pushConfig,
  });

  if (result.status !== "failed") {
    await markOutboxSent(args.adminClient, notificationId);
  } else {
    await releaseOutboxForRetry(args.adminClient, notificationId);
  }
}

export async function sendNotificationPush(args: {
  adminClient: SupabaseClient;
  notificationId: string;
  userId: string;
  type: string;
  metadata?: NotificationMetadata;
  targetRoute?: string | null;
  targetId?: string | null;
  title?: string;
  body?: string;
  data?: Record<string, string>;
  requestId: string;
  pushConfig?: FirebasePushConfig;
  bypassImportanceFilter?: boolean;
}): Promise<FirebasePushResult> {
  if (
    args.bypassImportanceFilter !== true &&
    !isHighImportanceNotification(args.type)
  ) {
    return { status: "skipped", attempted: 0, sent: 0, failed: 0 };
  }

  const envelope = buildNotificationEnvelope({
    type: args.type,
    metadata: args.metadata,
    targetRoute: args.targetRoute ?? undefined,
    targetId: args.targetId ?? undefined,
  });
  const content = buildItalianPushContent({
    type: args.type,
    metadata: envelope.metadata,
    title: args.title,
    body: args.body,
  });

  return await sendFirebasePushToUser({
    adminClient: args.adminClient,
    userId: args.userId,
    message: {
      title: content.title,
      body: content.body,
      data: {
        ...buildPushData(envelope),
        notification_id: args.notificationId,
        ...(args.data ?? {}),
      },
    },
    requestId: args.requestId,
    config: args.pushConfig,
  });
}

async function markOutboxSent(
  adminClient: SupabaseClient,
  notificationId: string,
): Promise<void> {
  await adminClient
    .from("notification_push_outbox")
    .update({
      status: "sent",
      processed_at: new Date().toISOString(),
      last_error: null,
    })
    .eq("notification_id", notificationId);
}

async function claimOutboxForImmediateSend(
  adminClient: SupabaseClient,
  notificationId: string,
): Promise<void> {
  await adminClient
    .from("notification_push_outbox")
    .update({
      status: "processing",
      locked_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("notification_id", notificationId)
    .eq("status", "pending");
}

async function releaseOutboxForRetry(
  adminClient: SupabaseClient,
  notificationId: string,
): Promise<void> {
  await adminClient
    .from("notification_push_outbox")
    .update({
      status: "pending",
      locked_at: null,
      next_attempt_at: new Date(Date.now() + 60 * 1000).toISOString(),
      last_error: "fcm_send_failed",
      updated_at: new Date().toISOString(),
    })
    .eq("notification_id", notificationId);
}

function readErrorCode(error: unknown): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const value = Reflect.get(error, "code");
    if (typeof value === "string") return value;
  }
  return "";
}

function readErrorMessage(error: unknown): string {
  if (typeof error === "object" && error !== null && "message" in error) {
    const value = Reflect.get(error, "message");
    if (typeof value === "string") return value;
  }
  return "";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
