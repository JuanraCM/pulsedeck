const graphs = [];
for (const canvas of document.querySelectorAll('canvas[data-graph]')) {
  const readings = Number(canvas.dataset.readings);
  const unit = canvas.dataset.unit;
  const chart = new Chart(canvas, {
    type: 'line',
    data: {
      labels: new Array(readings).fill(''),
      datasets: [{
        data: new Array(readings).fill(null),
        borderColor: '#4fc3f7', borderWidth: 2, pointRadius: 0, tension: 0
      }]
    },
    options: {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false }, tooltip: { enabled: false } },
      scales: {
        x: { display: false },
        y: {
          afterBuildTicks: (axis) => { axis.ticks = [{ value: axis.min }, { value: axis.max }]; },
          ticks: { color: '#999', callback: (v) => `${Number(v.toFixed(2))} ${unit}` },
          grid: { color: '#333' }
        }
      }
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
