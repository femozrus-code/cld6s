// Diagnostic-only build: reports exactly what element receives each tap so we
// can see, on-device, whether a real button is being hit or something
// invisible (an unclosed modal backdrop, a mis-sized overlay, pointer-events:
// none on the button itself, etc.) is swallowing the touch. Safe to strip out
// once the real fix is known — this file makes no changes to page behavior,
// it only observes and reports.
(function () {
  function describe(el) {
    if (!el) return null;
    try {
      var r = el.getBoundingClientRect();
      var cs = window.getComputedStyle(el);
      var cls = "";
      if (el.className) {
        cls = typeof el.className === "string" ? el.className : (el.className.baseVal || "");
      }
      return {
        tag: el.tagName,
        id: el.id || null,
        cls: cls.slice(0, 80),
        text: (el.innerText || el.textContent || "").trim().slice(0, 40),
        rect: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
        pe: cs.pointerEvents,
        opacity: cs.opacity,
        vis: cs.visibility,
        z: cs.zIndex,
        disp: cs.display,
      };
    } catch (e) {
      return { err: String(e && e.message ? e.message : e) };
    }
  }

  function send(obj) {
    try {
      window.webkit.messageHandlers.tapDebug.postMessage(obj);
    } catch (e) {}
  }

  var lastErr = null;
  window.addEventListener(
    "error",
    function (e) {
      lastErr = e && e.message;
    },
    true
  );

  document.addEventListener(
    "touchstart",
    function (ev) {
      var t = ev.touches && ev.touches[0];
      var x = t ? t.clientX : null;
      var y = t ? t.clientY : null;
      var atPoint = x != null ? document.elementFromPoint(x, y) : null;
      send({
        phase: "touchstart",
        x: x,
        y: y,
        target: describe(ev.target),
        atPoint: atPoint && atPoint !== ev.target ? describe(atPoint) : null,
        lastErr: lastErr,
      });
    },
    true
  );

  document.addEventListener(
    "click",
    function (ev) {
      send({
        phase: "click",
        target: describe(ev.target),
        defaultPrevented: ev.defaultPrevented,
        lastErr: lastErr,
      });
    },
    true
  );
})();
