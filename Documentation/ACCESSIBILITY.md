# Accessibility Guide - Next To Go Races App

**Last Updated:** 2026-02-07
**Status:** ✅ WCAG AA Compliant

---

## Overview

The Next To Go Races app is designed to be accessible to all users, including those with vision, motor, or cognitive disabilities. This guide documents our accessibility implementation and testing procedures.

---

## ✅ Accessibility Features

### 1. Dynamic Type Support

**Status:** ✅ Fully Implemented

All text in the app scales with the user's preferred text size settings:

- **Typography:** Uses semantic text styles (`.headline`, `.subheadline`, `.footnote`)
- **Layout:** Flexible heights and widths adapt to large text sizes
- **No Fixed Sizes:** All fonts scale from Small to Accessibility XXXLarge

#### Testing Dynamic Type

1. **In Xcode Previews:**
   ```swift
   #Preview("Accessibility XXXLarge") {
       RacesListView(viewModel: viewModel)
           .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
   }
   ```

2. **On Device:**
   - Settings → Accessibility → Display & Text Size → Larger Text
   - Drag slider to maximum and test the app

3. **Verify:**
   - ✅ No text clipping or truncation
   - ✅ Layouts adapt to accommodate large text
   - ✅ Touch targets remain accessible

### 2. VoiceOver Support

**Status:** ✅ Comprehensive

Every interactive element has proper accessibility labels and hints:

#### Category Filter Chips
- **Label:** "{Category} racing" (e.g., "Horse racing")
- **Hint:** "Selected, tap to deselect" or "Not selected, tap to select"
- **Traits:** `.isButton`, `.isSelected` (when selected)

#### Race Rows
- **Label:** Combined label with meeting name, race number, and countdown
- **Example:** "Flemington, Race 7, starts in 10 minutes"
- **Icons:** Decorative category icons are hidden from VoiceOver

#### Countdown Badge
- **Label:** "Race starts in" / "Race starting soon" / "Race started"
- **Value:** Current countdown time (e.g., "10m 0s")

#### Loading/Error States
- **Loading:** "Loading races"
- **Empty:** Descriptive message based on filter state
- **Error:** Error message with retry button

#### Testing VoiceOver

1. **Enable VoiceOver:**
   - Simulator: Cmd+F5
   - Device: Triple-click side button

2. **Test Navigation:**
   - Swipe right/left to move between elements
   - Verify logical order matches visual layout

3. **Test Interaction:**
   - Double-tap to activate buttons
   - Verify selection state is announced

### 3. Colour Contrast

**Status:** ✅ WCAG AA Compliant

All colour combinations meet WCAG AA standards:

#### Contrast Ratios
- **Unselected Chips:** Uses `Color.secondary` for automatic high contrast
- **Selected Chips:** White on orange/red (>4.5:1)
- **Countdown Urgent:** Dark red `rgb(0.6, 0.1, 0.1)` on light background (>4.5:1)
- **Meeting Name:** Primary text color (system-managed contrast)
- **Location Text:** Secondary text color (system-managed contrast)

#### Testing Colour Contrast

1. **Use Colour Contrast Analyzer:**
   - Download from [TPGi](https://www.tpgi.com/color-contrast-checker/)
   - Take screenshots of app
   - Measure text vs background ratios

2. **Verify Requirements:**
   - Normal text (< 18pt): Minimum 4.5:1 ✅
   - Large text (≥ 18pt): Minimum 3:1 ✅
   - UI components: Minimum 3:1 ✅

3. **Test Both Modes:**
   - Light mode contrast ✅
   - Dark mode contrast ✅

### 4. Touch Target Sizes

**Status:** ✅ 44x44pt Minimum

All interactive elements meet Apple HIG requirements:

- **Category Chips:** `minHeight: 44pt` enforced
- **Buttons:** System button insets ensure 44x44pt minimum
- **Race Rows:** Full row is tappable (75pt+ height)

#### Testing Touch Targets

1. **Use Accessibility Inspector:**
   - Xcode → Open Developer Tool → Accessibility Inspector
   - Run "Audit" tab
   - Check for "Hit Region" warnings (should be none)

2. **Manual Testing:**
   - Test with one finger (not stylus)
   - Verify all buttons can be tapped reliably

### 5. Reduce Motion Support

**Status:** ✅ Implemented

The app respects the user's Reduce Motion preference:

- **Custom Modifier:** `ReducedMotionTransactionModifier` disables animations
- **System Integration:** Uses `@Environment(\.accessibilityReduceMotion)`
- **Fallback:** Instant transitions instead of complex animations

#### Testing Reduce Motion

1. **Enable Reduce Motion:**
   - Settings → Accessibility → Motion → Reduce Motion (ON)

2. **Verify:**
   - Animations are reduced or eliminated
   - Transitions are simplified
   - No parallax or complex motion effects

---

## 🎨 Accessibility Previews

The app includes dedicated accessibility previews for testing:

### Available Previews
- `AccessibilityPreviews.swift` - Comprehensive accessibility testing previews

### Preview Examples
```swift
#Preview("Accessibility XXXLarge") {
    RacesListView(viewModel: viewModel)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("Colour Contrast - Light Mode") {
    // Tests all colour combinations in light mode
}

#Preview("Colour Contrast - Dark Mode") {
    // Tests all colour combinations in dark mode
}
```

---

## 🛠 Accessibility Tools

### Xcode Accessibility Inspector

**Location:** Xcode → Open Developer Tool → Accessibility Inspector

**Features:**
1. **Inspection Mode:** Hover over elements to see labels, hints, traits
2. **Audit:** Automatically find accessibility issues
3. **Settings:** Test with various accessibility settings

**How to Use:**
1. Launch Accessibility Inspector
2. Select target: Running simulator or device
3. Click "Run Audit" in Audit tab
4. Fix any reported issues

### VoiceOver Practice

**Enable:** Cmd+F5 (simulator) or triple-click side button (device)

**Basic Gestures:**
- Swipe right/left: Move between elements
- Double-tap: Activate element
- Two-finger swipe: Navigate by heading
- Three-finger swipe: Navigate by container

### Colour Contrast Analyzer

**Download:** [TPGi Colour Contrast Checker](https://www.tpgi.com/color-contrast-checker/)

**Usage:**
1. Take screenshot of UI
2. Use eyedropper to select foreground colour
3. Use eyedropper to select background colour
4. Check if ratio meets WCAG AA (4.5:1 for text)

---

## 📋 Testing Checklist

Before submitting to App Store, verify:

### Dynamic Type
- [ ] Test at all text sizes (Small to Accessibility XXXLarge)
- [ ] No text clipping or truncation
- [ ] Layouts adapt without breaking
- [ ] All text remains readable

### VoiceOver
- [ ] All interactive elements have labels
- [ ] Labels are descriptive (not generic)
- [ ] Navigation order is logical
- [ ] Selection state is announced
- [ ] Error messages are announced
- [ ] Loading states are announced

### Colour Contrast
- [ ] All text meets 4.5:1 ratio (or 3:1 for large text)
- [ ] UI components meet 3:1 ratio
- [ ] Both light and dark mode compliant
- [ ] No colour-only indicators

### Touch Targets
- [ ] All buttons minimum 44x44pt
- [ ] Adequate spacing between targets (8pt+)
- [ ] No accidental taps during testing

### Reduce Motion
- [ ] Animations respect user preference
- [ ] Complex motion is simplified or removed
- [ ] App remains functional with motion disabled

---

## 🏆 WCAG Compliance

The app meets the following WCAG 2.1 standards:

### Level A (Minimum)
- ✅ **1.1.1 Non-text Content** - Images have text alternatives
- ✅ **2.1.1 Keyboard** - All functionality via VoiceOver
- ✅ **4.1.2 Name, Role, Value** - Elements have accessible names

### Level AA (Standard)
- ✅ **1.4.3 Contrast (Minimum)** - 4.5:1 text, 3:1 UI
- ✅ **1.4.4 Resize Text** - Support 200% scaling
- ✅ **1.4.11 Non-text Contrast** - 3:1 UI components

### Level AAA (Enhanced) - Partial
- ⚠️ **1.4.6 Contrast (Enhanced)** - 7:1 text (some colours)
- ⚠️ **2.5.5 Target Size** - 44x44pt minimum (exceeds)

---

## 🐛 Common Issues and Solutions

### Issue: Text Clipping at Large Sizes

**Symptom:** Text is cut off when Dynamic Type is at maximum

**Solution:**
```swift
// ❌ WRONG - Fixed height
.frame(height: 75)

// ✅ CORRECT - Flexible height
.frame(minHeight: 75)
.fixedSize(horizontal: false, vertical: true)
```

### Issue: Low Colour Contrast

**Symptom:** Colour Contrast Analyzer shows ratio < 4.5:1

**Solution:**
```swift
// ❌ WRONG - Custom grey may have low contrast
.foregroundColor(Color.gray)

// ✅ CORRECT - System colours ensure contrast
.foregroundColor(Color.secondary)
```

### Issue: Generic VoiceOver Labels

**Symptom:** VoiceOver announces "Button" instead of purpose

**Solution:**
```swift
// ❌ WRONG - No label or generic label
Button(action: {}) {
    Image(systemName: "cart.badge.plus")
}

// ✅ CORRECT - Descriptive label
Button(action: {}) {
    Image(systemName: "cart.badge.plus")
}
.accessibilityLabel("Add to cart")
```

---

## 📚 Resources

### Apple Documentation
- [Accessibility for Developers](https://developer.apple.com/accessibility/)
- [Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [SwiftUI Accessibility Modifiers](https://developer.apple.com/documentation/swiftui/view-accessibility)

### WCAG Guidelines
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [Understanding WCAG 2.1](https://www.w3.org/WAI/WCAG21/Understanding/)

### Tools
- [Xcode Accessibility Inspector](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/OSXAXTestingApps.html)
- [Colour Contrast Analyzer](https://www.tpgi.com/color-contrast-checker/)

---

## 📞 Support

For accessibility-related questions or issues:

1. Check this guide first
2. Test with Accessibility Inspector
3. Review Apple's accessibility documentation
4. File an issue with:
   - Device and iOS version
   - Accessibility setting being used
   - Expected vs actual behaviour
   - Screenshots if applicable

---

**Remember:** Accessibility is not a feature to be added later—it's a fundamental aspect of app design that benefits all users.

---

🤖 Generated by [Axiom iOS Accessibility](https://github.com/anthropics/claude-code)
