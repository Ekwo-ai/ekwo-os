/**
 * The icons the pages use, named once.
 *
 * Lucide only, and never an emoji: an emoji is a different drawing on every
 * machine and is read aloud by a screen reader as whatever its name happens to
 * be. A tile names its icon as a string in `data/capabilities.ts`, which keeps
 * that file free of components, and this is where a string becomes a drawing.
 *
 * Every icon here is decorative — the tile beside it says the same thing in
 * words — so they are all `aria-hidden` and none carries a label.
 *
 * **No glyph with a currency in it.** Lucide's `receipt` draws a dollar sign
 * on the slip, and a site for books kept in every currency does not put one
 * currency on its tiles — the VAT tile is a document instead. A test refuses
 * a name here that is a receipt or a currency.
 */

import type { ComponentType, ReactNode } from 'react';
import {
  Activity,
  Coins,
  BookCheck,
  Briefcase,
  CalendarClock,
  Boxes,
  Building2,
  ChartColumn,
  Check,
  Copy,
  Database,
  Download,
  EyeOff,
  FileText,
  Globe,
  Landmark,
  Leaf,
  PackageOpen,
  Plug,
  Menu,
  Moon,
  PenLine,
  Scale,
  ScanLine,
  Search,
  Send,
  ShieldCheck,
  ShoppingCart,
  Target,
  Sun,
  Terminal,
  Unlock,
  Unplug,
  Users,
  Rocket,
} from 'lucide-react';

type Icon = ComponentType<{ className?: string; strokeWidth?: number; 'aria-hidden'?: boolean }>;

const ICONS: Record<string, Icon> = {
  activity: Activity,
  bookCheck: BookCheck,
  briefcase: Briefcase,
  calendarClock: CalendarClock,
  boxes: Boxes,
  building: Building2,
  chartColumn: ChartColumn,
  check: Check,
  coins: Coins,
  copy: Copy,
  database: Database,
  download: Download,
  eyeOff: EyeOff,
  fileText: FileText,
  globe: Globe,
  landmark: Landmark,
  leaf: Leaf,
  menu: Menu,
  moon: Moon,
  packageOpen: PackageOpen,
  penLine: PenLine,
  plug: Plug,
  scale: Scale,
  scanLine: ScanLine,
  search: Search,
  send: Send,
  shieldCheck: ShieldCheck,
  shoppingCart: ShoppingCart,
  sun: Sun,
  target: Target,
  terminal: Terminal,
  unlock: Unlock,
  unplug: Unplug,
  users: Users,
  rocket: Rocket,
};

/** Draws the named icon, or nothing where the name is not one. */
export function Glyph({ name, className }: { name: string; className?: string }): ReactNode {
  const Component = ICONS[name];
  if (Component === undefined) return null;
  return <Component className={className ?? 'h-5 w-5'} strokeWidth={1.6} aria-hidden />;
}

/** The names this registry answers to, for the test that keeps data and icons in step. */
export const ICON_NAMES: string[] = Object.keys(ICONS);
