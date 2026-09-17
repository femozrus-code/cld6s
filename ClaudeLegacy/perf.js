// Old A9-class hardware struggles with claude.ai's transitions/animations far
// more than modern devices do. Most sites (including ones built with Framer
// Motion, which claude.ai uses) check `matchMedia('(prefers-reduced-motion:
// reduce)')` before animating anything, and skip the animation entirely when
// it's true — same mechanism as the real iOS Accessibility setting, just
// forced on for this app regardless of the device's actual setting. This is
// the most effective lever: it stops JS-driven animations before they start,
// rather than only hiding their visual effect after the fact.
(function () {
  var originalMatchMedia = window.matchMedia ? window.matchMedia.bind(window) : null;
  if (!originalMatchMedia) return;

  window.matchMedia = function (query) {
    if (typeof query === "string" && query.indexOf("prefers-reduced-motion") !== -1) {
      var mql = originalMatchMedia("(min-width: 0px)"); // always-true baseline query
      try {
        Object.defineProperty(mql, "matches", { value: true, configurable: true });
      } catch (e) {}
      mql.media = query;
      return mql;
    }
    return originalMatchMedia(query);
  };
})();
