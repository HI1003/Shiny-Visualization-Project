(function () {
  'use strict';
  function reveal(id) {
    const target = document.getElementById(id);
    if (!target || !target.getClientRects().length) return false;
    for (let node = target; node; node = node.parentElement) {
      if (node.tagName === 'DETAILS') node.open = true;
    }
    target.scrollIntoView({block:'start', behavior:'auto'});
    if (!target.hasAttribute('tabindex')) target.setAttribute('tabindex','-1');
    target.focus({preventScroll:true});
    return true;
  }
  let focusRequest = 0;
  function focusWhenReady(id) {
    const request = ++focusRequest;
    let attempts = 0;
    function attempt() {
      if (request !== focusRequest) return;
      const target = document.getElementById(id);
      if (target && target.tagName === 'DETAILS') target.open = true;
      if (target && target.getClientRects().length &&
          !document.documentElement.classList.contains('shiny-busy') &&
          (!id.endsWith('-practice') || target.querySelector('.practice-progress'))) {
        reveal(id);return;
      }
      if (++attempts < 300) setTimeout(attempt,100);
    }
    attempt();
  }
  document.addEventListener('click',function(event) {
    if (event.target.closest('.nav-sidebar a, .learning-section-nav a')) ++focusRequest;
    const link = event.target.closest('a[data-learning-jump]');
    if (!link) return;
    event.preventDefault();
    reveal(link.dataset.learningJump);
  });
  let resizeTimer;
  let mathTimer, mathPending = false;
  function refreshMath(force) {
    if (mathPending) return;
    clearTimeout(mathTimer);
    mathTimer = setTimeout(function() {
      const active = document.querySelector('.tab-pane.active .learning-module');
      if (!active || !window.MathJax || !MathJax.Hub) return;
      const frames = Array.from(active.querySelectorAll('.MathJax,.MathJax_SVG'));
      const needsRepair = frames.some(function(frame) {
        return frame.getClientRects().length && frame.getBoundingClientRect().width < 1;
      });
      if (!force && !needsRepair) return;
      mathPending = true;
      MathJax.Hub.Queue(['Rerender',MathJax.Hub,active],function() {mathPending=false;});
    },180);
  }
  function resizePlots() {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function() {
      window.dispatchEvent(new Event('resize'));
      if (window.Plotly) document.querySelectorAll('.js-plotly-plot').forEach(function(plot) {
        if (plot.getClientRects().length) window.Plotly.Plots.resize(plot);
      });
      refreshMath(true);
    },160);
  }
  document.addEventListener('toggle',resizePlots,true);
  document.addEventListener('DOMContentLoaded',function() {
    const content = document.querySelector('.content-wrapper');
    let previousWidth = 0;
    if (content && window.ResizeObserver) new ResizeObserver(function(entries) {
      const width = entries[0].contentRect.width;
      if (Math.abs(width-previousWidth)>1) { previousWidth=width;resizePlots(); }
    }).observe(content);
    if (content) new MutationObserver(function() {refreshMath(false);}).observe(content,{childList:true,subtree:true});
    if (window.jQuery) jQuery(document).on('shown.bs.tab',resizePlots);
    if (window.Shiny) Shiny.addCustomMessageHandler('learning-focus',function(message) {focusWhenReady(message.id);});
  });
})();
