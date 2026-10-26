# Notice and attribution

## GymMane (design and component origin)

The look and feel of this package (tokens, the liquid navigation bar, glass sheets
and dialogs, the springy press, the screen-switch motion, rising entrances, rolling
digits, shimmer, the progressive edge blur and its shader) is adapted from
**GymMane**, copyright (C) 2026 InlitX: https://github.com/InlitX/GymMane

* GymMane's code is licensed `GPL-3.0-only` with an additional attribution term
  (Section 7(b), file `ADDITIONAL_TERMS.md` in that repository: works that contain
  GymMane must retain the notice "Based on GymMane by InlitX").
* The repository owner reports that GymMane's author has said the **UI may be freely
  borrowed** and that the license is meant for the GymMane *app*, not its UI.
  That permission was given verbally. **Record it in writing** (an issue comment on
  the GymMane repository, or an e-mail saved in this repository) before relying on
  it commercially. Until then, the safe reading is that GPL-3.0 applies to anything
  copied from GymMane.
* Regardless of the license question, keep a credit such as "UI based on GymMane by
  InlitX" in the About screen of apps that use this package. It costs nothing and is
  what the GymMane terms ask for.

Everything in this repository was rewritten for this package (widgets parameterized
by `UiTheme`, desktop support, tests, theme builder, adaptive shell, toast, page
transitions). Notable changes from the original: the navigation bar takes any
number of items and an optional action button; the sheet becomes a centered panel
on desktop; buttons gained keyboard, focus and hover handling; fonts, radii, motion
and shadows are tokens instead of constants; the phone-cutout "liquid notch" toast
was replaced with a desktop-safe toast.

## Nunito

`fonts/Nunito-*.ttf`: Copyright 2014 The Nunito Project Authors, licensed under the
SIL Open Font License 1.1. See `fonts/Nunito-OFL.txt`. The font may be bundled and
redistributed with software, but not sold on its own.

## This repository's own license

No `LICENSE` file is included on purpose. Decide it with the clinic project's
requirements in mind:

* If the written permission above says the UI is free to reuse without conditions,
  any license (including a proprietary one) is possible for the rewritten code.
* If it does not, GPL-3.0 applies and the clinic app that links this package would
  also need to be GPL-3.0 when distributed.
