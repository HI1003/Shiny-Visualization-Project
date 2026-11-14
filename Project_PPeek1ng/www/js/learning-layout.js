(function () {
  'use strict';
  // Link distribution tooltips in the browser, so moving the pointer never
  // requests a new R plot. Discrete CDFs also expose every step interval.
  let linkingDistribution = false;
  window.learningLinkDistributionPlot = function (el, meta) {
    if (el._distributionHandlers) {
      Object.entries(el._distributionHandlers).forEach(function(entry) {
        el.removeListener(entry[0],entry[1]);
      });
      el.removeEventListener('pointerup',el._distributionTap);
      el.removeEventListener('pointerdown',el._distributionPointer);
      el.removeEventListener('pointermove',el._distributionPointer);
      el.removeEventListener('pointerleave',el._distributionLeave);
    }
    el._distributionMeta = meta;
    el._distributionIndex = null;
    el._distributionPinned = false;
    el._distributionCursorX = null;
    function peer() {
      const root = document.getElementById(meta.peerId);
      return root && (root.classList.contains('js-plotly-plot') ? root : root.querySelector('.js-plotly-plot'));
    }
    function pair() { return [el,peer()].filter(function(p) {return p && p._distributionMeta;}); }
    function resetCursor(plot) {
      plot._distributionCursorX = null;
      plot.querySelectorAll('.learning-distribution-readout,.learning-distribution-cursor').forEach(function(node) {
        node.style.display='none';
        node.textContent='';
      });
    }
    function cursorNode(plot,className) {
      let node=plot.querySelector('.'+className);
      if(!node) {
        node=document.createElement('div');
        node.className=className;
        plot.appendChild(node);
      }
      node.style.display='block';
      return node;
    }
    function showCursorReading(plot,x,value,text) {
      const layout=plot._fullLayout;
      const left=layout.xaxis._offset+layout.xaxis.l2p(x);
      const finite=Number.isFinite(value);
      const top=layout.yaxis._offset+(finite ? layout.yaxis.l2p(value) : 0);
      const color=plot._distributionMeta.kind==='bar' ? '#2171b5' : plot._distributionMeta.color;
      const marker=cursorNode(plot,'learning-distribution-cursor');
      marker.style.backgroundColor=color;
      marker.style.left=left+'px';
      marker.style.top=top+'px';
      marker.style.display=finite ? 'block' : 'none';
      const readout=cursorNode(plot,'learning-distribution-readout');
      readout.style.backgroundColor=color;
      readout.style.color=plot._distributionMeta.kind==='curve' && !plot._distributionMeta.probability ? '#17212b' : '#fff';
      readout.textContent=text;
      const insideAxes=plot._distributionMeta.kind==='curve';
      const minimumLeft=insideAxes ? layout.xaxis._offset+4 : 6;
      const maximumRight=insideAxes ? layout.xaxis._offset+layout.xaxis._length-4 : plot.clientWidth-6;
      readout.style.maxWidth=Math.max(1,maximumRight-minimumLeft)+'px';
      const labelLeft=left+12+readout.offsetWidth<maximumRight ? left+12 : left-readout.offsetWidth-12;
      readout.style.left=Math.max(minimumLeft,Math.min(labelLeft,maximumRight-readout.offsetWidth))+'px';
      readout.style.top=Math.max(6,Math.min(top-readout.offsetHeight-8,plot.clientHeight-readout.offsetHeight-6))+'px';
    }
    function showAtX(x,pinned) {
      if(meta.kind==='curve') {
        const xs=meta.reading.x;
        let nearest=0;
        xs.forEach(function(value,index) {if(Math.abs(value-x)<Math.abs(xs[nearest]-x)) nearest=index;});
        show(nearest,pinned);
        return;
      }
      if(linkingDistribution) return;
      const plots=pair();
      const cdf=plots.find(function(plot) {return plot._distributionMeta.kind==='point';});
      if(!cdf || !cdf._distributionMeta.reading) return;
      const reading=cdf._distributionMeta.reading;
      const outcome=reading.k.indexOf(x);
      const cumulativeIndex=reading.k.findLastIndex(function(k) {return k<=x;});
      const probability=outcome<0 ? 0 : reading.probability[outcome];
      const cumulative=cumulativeIndex<0 ? 0 : reading.cumulative[cumulativeIndex];
      const probabilityText=outcome<0 ? '= 0' : reading.probabilityText[outcome];
      const cumulativeText=cumulativeIndex<0 ? '= 0' : reading.cumulativeText[cumulativeIndex];
      const shownX=String(Number(x.toFixed(4)));
      linkingDistribution=true;
      try {
        plots.forEach(function(plot) {
          plot._distributionPinned=pinned;
          const index=plot.data[0].x.indexOf(x);
          highlight(plot,index<0 ? null : index);
          Plotly.Fx.unhover(plot);
          plot._distributionCursorX=x;
          const isPmf=plot._distributionMeta.kind==='bar';
          const text=isPmf ? 'P(X = '+shownX+') '+probabilityText : 'F('+shownX+') = P(X ≤ '+shownX+') '+cumulativeText;
          showCursorReading(plot,x,isPmf ? probability : cumulative,'x = '+shownX+'\n'+text);
        });
      } finally {linkingDistribution=false;}
    }
    function pointerX(event) {
      if(!el._fullLayout) return null;
      const rect=el.getBoundingClientRect(),layout=el._fullLayout;
      const px=event.clientX-rect.left-layout.xaxis._offset;
      const py=event.clientY-rect.top-layout.yaxis._offset;
      if(px< -2 || px>layout.xaxis._length+2 || py< -2 || py>layout.yaxis._length+2) return null;
      let x=layout.xaxis.p2d(Math.max(0,Math.min(px,layout.xaxis._length)));
      const integer=Math.round(x);
      // Snap to the included endpoint when the pointer is on its marker.
      if(meta.kind==='point' && Math.abs(px-layout.xaxis.l2p(integer))<=2) x=integer;
      return x;
    }
    function highlight(plot,index) {
      plot._distributionIndex = index;
      if (plot._distributionMeta.kind === 'bar') {
        plot.querySelectorAll('.barlayer .point path').forEach(function(bar,i) {
          bar.style.fill = i === index ? '#2171b5' : plot._distributionMeta.color;
        });
      } else if (plot._distributionMeta.kind === 'point') {
        const trace = plot.querySelector('.scatterlayer .trace');
        if (trace) trace.querySelectorAll('.point').forEach(function(point,i) {
          point.style.strokeWidth = i === index ? '4px' : '0px';
          point.style.stroke = plot._distributionMeta.color;
        });
      }
    }
    function show(index,pinned) {
      if (linkingDistribution || !Number.isInteger(index)) return;
      if(meta.kind==='bar' && pinned) {
        showAtX(el.data[0].x[index],true);
        return;
      }
      const plots = pair();
      if (meta.kind === 'curve' && (plots.length !== 2 || plots.some(function(plot) {
        return plot._distributionMeta.reading?.signature !== meta.reading?.signature;
      }))) return;
      linkingDistribution = true;
      try {
        const query=meta.kind==='curve' ? meta.reading : null;
        plots.forEach(function(plot) {
          resetCursor(plot);
          plot._distributionPinned = pinned;
          highlight(plot,index);
          if(query) {
            const x=query.x[index];
            const probability=plot._distributionMeta.probability;
            const value=probability ? query.cumulative[index] : query.density[index];
            plot._distributionCursorX=x;
            Plotly.Fx.unhover(plot);
            const detail=probability ? 'F(x) = P(X ≤ x) '+query.cumulativeText[index] :
              Number.isFinite(value) ? 'Density f(x) '+query.densityText[index]+'\nDensity is not P(X = x).' :
              'Density is unbounded at this endpoint.';
            showCursorReading(plot,x,value,'x = '+query.labels[index]+'\n'+detail);
            return;
          }
          // Native discrete-point tooltips require a finite plotted value.
          if (Number.isFinite(plot.data[0].y[index])) {
            Plotly.Fx.hover(plot,[{curveNumber:0,pointNumber:index}]);
          } else Plotly.Fx.unhover(plot);
        });
      } finally { linkingDistribution = false; }
    }
    function clear() {
      if (linkingDistribution) return;
      if (el._distributionPinned) {
        const index=el._distributionIndex;
        const x=el._distributionCursorX;
        setTimeout(function() {
          if(el._distributionPinned) {
            if(x!==null) showAtX(x,true);
            else show(index,true);
          }
        },0);
        return;
      }
      linkingDistribution = true;
      try {pair().forEach(function(plot) {resetCursor(plot);highlight(plot,null);Plotly.Fx.unhover(plot);});}
      finally {linkingDistribution = false;}
    }
    const handlers = {
      plotly_beforehover:function() {return meta.kind!=='point' && meta.kind!=='curve';},
      plotly_hover:function(event) {
        if(meta.kind==='curve') return;
        if (!Array.isArray(event?.points)) return;
        const point = event.points.find(function(p) {return p.curveNumber === 0;});
        if (point) show(point.pointNumber,el._distributionPinned);
      },
      plotly_unhover:function() {if(el._distributionCursorX===null) clear();},
      plotly_click:function(event) {
        if(meta.kind==='curve') return;
        if (!Array.isArray(event?.points)) return;
        const point = event.points.find(function(p) {return p.curveNumber === 0;});
        if (point) show(point.pointNumber,el._distributionPinned);
      }
    };
    Object.entries(handlers).forEach(function(entry) {el.on(entry[0],entry[1]);});
    el._distributionHandlers = handlers;
    el._distributionTap = function(event) {
      if (event.pointerType !== 'touch' || !el._fullLayout) return;
      if(meta.kind==='point' || meta.kind==='curve') {
        const x=pointerX(event);
        if(x!==null) showAtX(x,true);
        return;
      }
      const rect=el.getBoundingClientRect(),axis=el._fullLayout.xaxis;
      const px=event.clientX-rect.left-axis._offset;
      const py=event.clientY-rect.top-el._fullLayout.yaxis._offset;
      if (px<0 || px>axis._length || py<0 || py>el._fullLayout.yaxis._length) return;
      const x=axis.p2d(px),xs=el.data[0].x;
      let nearest=0;
      xs.forEach(function(value,i) {if(Math.abs(value-x)<Math.abs(xs[nearest]-x)) nearest=i;});
      // Plotly clears its native touch hover while finishing the tap. Restore
      // the paired tooltip after that event stack, rather than fighting it.
      show(nearest,true);
      setTimeout(function() {if(el._distributionPinned) show(nearest,true);},0);
    };
    el._distributionPointer = function(event) {
      if (event.pointerType !== 'mouse') return;
      pair().forEach(function(plot) {plot._distributionPinned=false;});
      if(meta.kind==='point' || meta.kind==='curve') {
        const x=pointerX(event);
        if(x===null) clear();
        else showAtX(x,false);
      } else pair().forEach(resetCursor);
    };
    el._distributionLeave=clear;
    el.addEventListener('pointerup',el._distributionTap);
    el.addEventListener('pointerdown',el._distributionPointer);
    el.addEventListener('pointermove',el._distributionPointer);
    el.addEventListener('pointerleave',el._distributionLeave);
    resetCursor(el);
    // A parameter/model update invalidates the old hover in either plot.
    const other=peer();
    if(other && other._distributionMeta) {
      other._distributionPinned=false;
      resetCursor(other);
      highlight(other,null);Plotly.Fx.unhover(other);
    }
  };
  function parameterPrecisionStep(value, defaultStep) {
    const parts = String(value).toLowerCase().split('e');
    const decimals = (parts[0].split('.')[1] || '').length - Number(parts[1] || 0);
    return Math.min(defaultStep, Math.pow(10, -Math.max(0, decimals)));
  }
  function renderParameterTicks(slider, defaultStep) {
    const grid = slider.$cache.grid[0];
    if (!grid) return;
    const previous = grid.querySelector('.learning-parameter-ticks');
    if (previous) previous.remove();
    const min = slider.options.min, max = slider.options.max;
    const rawStep = (max - min) / 10;
    if (!(rawStep > 0)) return;
    const scale = Math.pow(10, Math.floor(Math.log10(rawStep)));
    const factor = [1, 2, 2.5, 3, 5, 10].find(value => value >= rawStep / scale - 1e-10);
    const tickStep = Math.max(defaultStep, factor * scale);
    const ticks = document.createElement('div');
    ticks.className = 'learning-parameter-ticks';
    ticks.setAttribute('aria-hidden', 'true');
    for (let index = Math.ceil(min / tickStep - 1e-10); index * tickStep <= max + 1e-10; index++) {
      const value = Number((index * tickStep).toFixed(10));
      const position = (value - min) / (max - min) * 100 + '%';
      const mark = document.createElement('span');
      mark.className = 'irs-grid-pol';
      mark.style.left = position;
      const label = document.createElement('span');
      label.className = 'irs-grid-text';
      label.style.left = position;
      label.textContent = String(value);
      ticks.append(mark, label);
    }
    grid.appendChild(ticks);
  }
  function setupParameterInputs() {
    document.querySelectorAll('.learning-parameter-number').forEach(function(numberInput) {
      if (numberInput.dataset.connected) return;
      const sliderInput = document.getElementById(numberInput.dataset.parameterSlider);
      const slider = jQuery(sliderInput).data('ionRangeSlider');
      if (!slider) return;
      const defaultStep = Number(numberInput.dataset.parameterStep);
      const integer = numberInput.dataset.parameterInteger === 'true';
      const parameter = numberInput.closest('.learning-parameter');
      // The bundled slider treats scientific-notation steps as integers otherwise.
      slider.convertToValue = function(percent) {
        if (percent === 0) return this.options.min;
        if (percent === 100) return this.options.max;
        const value = this.options.min + percent / 100 * (this.options.max - this.options.min);
        const decimals = Math.min(20, Math.max(0, Math.round(-Math.log10(this.options.step))));
        return Math.max(this.options.min, Math.min(this.options.max, Number(value.toFixed(decimals))));
      };
      // Anchor interaction steps to zero, including sliders whose valid minimum is 0.01.
      slider.calcWithStep = function(percent) {
        if (percent === 0 || percent === 100) return percent;
        const value = this.options.min + percent / 100 * (this.options.max - this.options.min);
        const step = this.options.step;
        const decimals = Math.min(20, Math.max(0, -Math.floor(Math.log10(step))));
        const rounded = Number((Math.round(value / step) * step).toFixed(decimals));
        const bounded = Math.max(this.options.min, Math.min(this.options.max, rounded));
        return this.convertToPercent(bounded);
      };
      const error = document.getElementById(sliderInput.id + '-error');
      function showError(message) {
        numberInput.setCustomValidity(message);
        numberInput.setAttribute('aria-invalid', message ? 'true' : 'false');
        error.textContent = message;
        error.hidden = !message;
      }
      function syncFromSlider() {
        numberInput.min = slider.options.min;
        numberInput.max = slider.options.max;
        numberInput.value = slider.result.from;
        showError('');
        renderParameterTicks(slider, defaultStep);
      }
      function validationMessage() {
        const value = numberInput.valueAsNumber;
        if (!Number.isFinite(value)) return 'Enter a number.';
        if (integer && !Number.isInteger(value)) return 'Enter a whole number.';
        if (value < slider.options.min || value > slider.options.max) {
          return 'Enter a value from ' + slider.options.min + ' to ' + slider.options.max + '.';
        }
        // Uniform bounds must describe a non-empty interval.
        if (sliderInput.id.endsWith('-a_unif')) {
          const upper = document.getElementById(sliderInput.id.replace(/a_unif$/, 'b_unif'));
          if (value >= Number(upper.value)) return 'The lower bound must be less than the upper bound.';
        }
        if (sliderInput.id.endsWith('-b_unif')) {
          const lower = document.getElementById(sliderInput.id.replace(/b_unif$/, 'a_unif'));
          if (value <= Number(lower.value)) return 'The upper bound must be greater than the lower bound.';
        }
        return '';
      }
      function commit() {
        const message = validationMessage();
        showError(message);
        if (message) return;
        const value = numberInput.valueAsNumber;
        // Enter followed by blur must not recreate the slider during a drag.
        if (value === slider.result.from) return;
        // Ion RangeSlider otherwise rounds a typed value to its drag step.
        const step = parameterPrecisionStep(value, defaultStep);
        slider.update({from:value, step:step});
        // Use the same input binding and plot calculations as a slider drag.
        jQuery(sliderInput).trigger('change');
      }
      function increment(direction) {
        const current = Number.isFinite(numberInput.valueAsNumber) ? numberInput.valueAsNumber : slider.result.from;
        const scaled = current / defaultStep;
        const index = direction > 0 ? Math.floor(scaled + 1e-10) + 1 : Math.ceil(scaled - 1e-10) - 1;
        const next = Number((index * defaultStep).toFixed(10));
        numberInput.value = Math.max(slider.options.min, Math.min(slider.options.max, next));
        commit();
      }
      function prepareSlider(event) {
        if (!event.target.closest('.irs')) return;
        // Changing these two values keeps an in-progress drag attached to its handle.
        slider.options.step = defaultStep;
        slider.coords.p_step = slider.convertToPercent(defaultStep, true);
      }
      parameter.addEventListener('mousedown', prepareSlider, true);
      parameter.addEventListener('touchstart', prepareSlider, true);
      parameter.addEventListener('keydown', prepareSlider, true);
      parameter.querySelectorAll('[data-parameter-direction]').forEach(function(button) {
        button.addEventListener('click', function() {increment(Number(button.dataset.parameterDirection));});
      });
      numberInput.addEventListener('input', function() {showError(validationMessage());});
      numberInput.addEventListener('change', commit);
      numberInput.addEventListener('keydown', function(event) {
        if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
          event.preventDefault();
          increment(event.key === 'ArrowUp' ? 1 : -1);
        } else if (event.key === 'Enter') {
          event.preventDefault();
          commit();
          if (numberInput.getAttribute('aria-invalid') === 'false') numberInput.blur();
        }
      });
      jQuery(sliderInput).on('change.learningParameter', syncFromSlider);
      numberInput.dataset.connected = 'true';
      syncFromSlider();
    });
  }
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
    if (window.jQuery) {
      jQuery(document).on('shown.bs.tab',resizePlots);
      jQuery(document).on('shiny:bound shiny:connected',setupParameterInputs);
      jQuery(document).on('shiny:updateinput', '.learning-parameter input.js-range-slider', function(event) {
        const number = this.closest('.learning-parameter').querySelector('.learning-parameter-number');
        const value = event.message.value;
        if (typeof value === 'number' && Number.isFinite(value)) {
          event.message.step = parameterPrecisionStep(value, Number(number.dataset.parameterStep));
        }
      });
      setupParameterInputs();
    }
    if (window.Shiny) Shiny.addCustomMessageHandler('learning-focus',function(message) {focusWhenReady(message.id);});
  });
})();
