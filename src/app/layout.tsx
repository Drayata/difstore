import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Difstore", template: "%s | Difstore" },
  description: "Produk digital untuk belajar, bekerja, dan berkreasi.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="id">
      <body>{children}</body>
    </html>
  );
}
