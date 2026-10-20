import { NextResponse } from "next/server";

export const runtime = "edge";

export function GET() {
  return NextResponse.json({ data: { status: "ok", phase: 0 }, error: null });
}
