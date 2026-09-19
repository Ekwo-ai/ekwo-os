/**
 * The mark, and the word beside it.
 *
 * A leaf: two arcs meeting at a point, with the midrib drawn short. The name
 * reads as sustainability rather than as equality, and the placeholder it
 * replaces — two bars of equal weight in a rounded square — read as an equals
 * sign long before it read as the two sides of an entry.
 *
 * The midrib stops well before both tips, and that is the whole drawing. Run
 * it tip to tip and it cuts the shell into two equal halves, which is what a
 * pod looks like, not a leaf; held short it floats inside the shape and the
 * form is a leaf again. It is also the only stroke here with room to spare, so
 * it is the one that survives the ink spreading at small sizes.
 *
 * It is drawn here rather than taken from the icon set, and it is not the
 * `leaf` of that set: a mark is read at 16 pixels in a browser tab, where
 * lucide's leaf loses its stem and half its curve. This one is built from two
 * strokes at a single weight, which is what survives that size. The two
 * drawings still rhyme, and they should — the icon of the carbon tile and the
 * mark of the product say the same thing.
 *
 * Never green. The colour is the cobalt accent, in `currentColor`, so the mark
 * takes whichever of the four palette-and-theme combinations the reader is in.
 * A leaf rendered green on a sustainability product is the cliché this mark is
 * meant to sidestep; the blue is what does the sidestepping.
 */

import type { ReactNode } from 'react';

/** The mark on its own, for the header, the footer and the favicon. */
export function Mark({ size, className }: { size: number; className?: string }): ReactNode {
  return (
    <svg
      viewBox="0 0 24 24"
      width={size}
      height={size}
      className={className}
      aria-hidden
      focusable="false"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M4.6 19.4C4.6 9.6 10.4 4 20 4c0 9.6-5.8 15.4-15.4 15.4Z" />
      <path d="M8.2 15.8 15.8 8.2" />
    </svg>
  );
}

/**
 * The mark and the name, as one link home.
 *
 * `size` is the type size; the mark is set just under it, the way a lockup
 * usually is.
 *
 * The gap is 6 and not the 10 the other sites in this workspace use, because
 * the leaf carries its own margin: its ink stops at 21 of the 24 units, so
 * roughly 3 more pixels of air sit between the shape and the word than the
 * number says. Six here is what nine looks like.
 */
export function Logo({ size = 24 }: { size?: number }): ReactNode {
  return (
    <a
      href="/"
      className="inline-flex items-center gap-[6px] font-serif font-semibold tracking-[-0.01em] text-ink no-underline"
      style={{ fontSize: `${size}px` }}
    >
      <Mark size={Math.round(size * 0.9)} className="shrink-0 text-brand" />
      <span>Ekwo</span>
    </a>
  );
}
