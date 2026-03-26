#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/catppuccin:1.0.1": catppuccin, flavors
#import "@preview/metropolyst:0.1.0": *
#import "@preview/cetz:0.4.2"
#import "@preview/obsidius:0.1.1": callout

#let catpuccin-template(
  doc, 
  dark-mode: false,
  bold-header: false,
) = {
  let (
    theme, 
    header, 
    focus-text, 
    header-text, 
    code-background,
    progress-background,
  ) = if dark-mode {
    (
      flavors.frappe, 
      flavors.frappe.colors.base.rgb, 
      flavors.frappe.colors.text.rgb,
      flavors.frappe.colors.text.rgb,
      flavors.frappe.colors.base.rgb.lighten(5%),
      flavors.latte.colors.text.rgb.lighten(10%)
    )
  } else {
    (
      flavors.latte, 
      flavors.frappe.colors.base.rgb.lighten(10%),
      flavors.frappe.colors.text.rgb,
      flavors.frappe.colors.text.rgb,
      flavors.latte.colors.base.rgb.darken(5%),
      flavors.latte.colors.base.rgb.darken(20%)
    )
  }

  show: catppuccin.with(theme)
  show raw.where(block: true): block.with(
    fill: code-background, 
    inset: 0.8em, 
    radius: 0.5em, 
    width: 100%
  )

  show: metropolyst-theme.with(
    footer-right: none,
    font: ("Fira Sans",),
    header-weight: if bold-header { "bold" } else { "regular" },
    accent-color: theme.colors.mauve.rgb,
    progress-bar-background: progress-background,
    hyperlink-color: theme.colors.blue.rgb,
    header-text-color: header-text,
    header-background-color: header,
    main-background-color: theme.colors.base.rgb,
    main-text-color: theme.colors.text.rgb,
    focus-text-color: focus-text,
    footer-progress: true,
    config-info(
      title: [Memory Management],
      subtitle: [myposter Academy],
      author: [Lukas Rieger],
    ),
  )

  doc
}

// Custom callout types using obsidius
// Unified mauve/violet coloring matching our theme accent, distinguished by title + emoji
#let _callout-colors = (flavors.latte.colors.mauve.rgb, flavors.latte.colors.mauve.rgb.lighten(85%), flavors.latte.colors.mauve.rgb.lighten(50%))

#let misconception(content) = callout(emoji.warning, "Common Misconception", content, _callout-colors)
#let didyouknow(content) = callout(emoji.lightbulb, "Did you know?", content, _callout-colors)
#let tldr(content) = callout(emoji.leaf, "TL;DR", content, _callout-colors)
#let furtherreading(content) = callout(emoji.books, "Further Reading", content, _callout-colors)
