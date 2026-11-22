const LABEL_HEIGHT = 16;
// Draws the max value above the line area and the min value below it, at the left edge.
// The Y axis is hidden, so it takes no width and the line never goes over the labels.
const minMaxLabels = {
  id: 'minMaxLabels',
  afterDraw(chart) {
    const { ctx, chartArea, scales: { y } } = chart;
    const unit = chart.canvas.dataset.unit;
    const format = (v) => `${Number(v.toFixed(2))} ${unit}`;
    ctx.save();
    ctx.font = '12px sans-serif';
    ctx.fillStyle = '#999';
    ctx.textBaseline = 'bottom';
    ctx.fillText(format(y.max), chartArea.left, chartArea.top - 2);
    ctx.textBaseline = 'top';
    ctx.fillText(format(y.min), chartArea.left, chartArea.bottom + 2);
    ctx.restore();
  }
};
const graphs = [];
for (const canvas of document.querySelectorAll('canvas[data-graph]')) {
  const readings = Number(canvas.dataset.readings);
  const chart = new Chart(canvas, {
    type: 'line',
    data: {
      labels: new Array(readings).fill(''),
      datasets: [{
        data: new Array(readings).fill(null),
        borderColor: '#4fc3f7', borderWidth: 2, pointRadius: 0, tension: 0
      }]
    },
    plugins: [minMaxLabels],
    options: {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      layout: { padding: { top: LABEL_HEIGHT, bottom: LABEL_HEIGHT } },
      plugins: { legend: { display: false }, tooltip: { enabled: false } },
      scales: { x: { display: false }, y: { display: false } }
    }
  });
  graphs.push({ id: canvas.dataset.graph, chart });
}
document.addEventListener('pulsedeck:values', (event) => {
  const values = event.detail;
  for (const { id, chart } of graphs) {
    if (!(id in values)) continue;
    const data = chart.data.datasets[0].data;
    data.push(values[id]);
    data.shift();
    chart.update('none');
  }
});
