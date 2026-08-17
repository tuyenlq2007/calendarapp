import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Barom Kagyu Calendar Admin",
  description: "Staff-authored Tibetan calendar publishing dashboard.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
