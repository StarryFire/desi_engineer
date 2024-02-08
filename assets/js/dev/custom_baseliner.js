function vw(percent) {
  var w = Math.max(
    document.documentElement.clientWidth,
    window.innerWidth || 0
  );
  return (percent * w) / 100;
}

function rem(rem) {
  return rem * parseFloat(getComputedStyle(document.documentElement).fontSize);
}

function clamp(min, current, max) {
  // console.log(min, current, max);
  current = Math.max(min, current);
  return Math.min(current, max);
}

function debounce(func, timeout = 300) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func.apply(this, args);
    }, timeout);
  };
}

function round(num, upto) {
  const multiplier = 10 ** upto;
  return Math.round(num * multiplier) / multiplier;
}

function getGridHeight() {
  return round(rem(0.7), 1);
}

function setGridHeight() {
  const gridHeight = getGridHeight();
  // console.log("setting grid height to: ", gridHeight);
  baseliner.grid_size.value = gridHeight;
  baseliner.refresh(gridHeight);
  console.log("1rem=", rem(1));
}
const debouncedSetGridHeight = debounce(() => setGridHeight());

window.onload = function () {
  const gridHeight = getGridHeight();
  // console.log("initializing grid height with: ", gridHeight);
  baseliner = new Baseliner({
    gridColor: [255, 255, 255],
    gridHeight: gridHeight,
    // gridOpacity: 100,
    // gridSpace: 5,
    // gridOffset: 0,
  });
  // console.log("1rem=", rem(1));

  baseliner.toggle();
  window.addEventListener("resize", debouncedSetGridHeight);
};
