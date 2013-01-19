$(function() {
	$.getJSON('http://localhost:4567/ressources/home/temperature?iface=analog.sensor.temperature.celcuis&start_time=', function(data) {
		// Create the chart
		window.chart = new Highcharts.StockChart({
		    chart: {
		        renderTo: 'container'
		    },

		    rangeSelector: {
		        selected: 1
		    },

		    title: {
		        text: 'AAPL Stock Price'
		    },
		    
		    series: [{
		        name: 'AAPL Stock Price',
		        data: data,
		        type: 'spline',
		        tooltip: {
		        	valueDecimals: 2
		        }
		    }]
		});
	});
});
