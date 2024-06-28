import { LightningElement , wire} from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartjs';
import gaugeJS from '@salesforce/resourceUrl/chartgauge';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getYear from '@salesforce/apex/SpeedTargetGraphController.getYear';
import getSaldept from '@salesforce/apex/SpeedTargetGraphController.getSaldept';
import searchRecords from '@salesforce/apex/SpeedTargetGraphController.searchRecords';

export default class SpeedTargetGraph extends LightningElement {
    chart1;
    chart2;
    chart3;
    chartjsInitialized = false;

    years = [];
    saldepts = [];
    Actual_Amount_TL = '';
    Target_Amount_TL = '';
    Actual_Amount_EUR = '';
    Target_Amount_EUR = '';
    Actual_Quantity = '';
    Target_Quantity = '';
    chart1oran = 0;
    chart2oran = 0;
    chart3oran = 0;
    error;

    @wire(getYear)
    wiredYears({ error, data }) {
        if (data) {
            this.years = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.years = undefined;
        }
    }

    @wire(getSaldept)
    wiredSaldepts({ error, data }) {
        if (data) {
            this.saldepts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.saldepts = undefined;
        }
    }

    

    config1 = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [30, 40, 30],
                    backgroundColor: ['red', 'yellow', 'green'],
                    borderWidth: 0,
                    hoverBackgroundColor: ['red', 'yellow', 'green'],
                    hoverBorderWidth: 0
                }
            ]
        },
        options: {
            cutoutPercentage: 70,
            rotation: -Math.PI,
            circumference: Math.PI,
            legend: {
                display: false
            },
            tooltips: {
                enabled: false
            },
            title: {
                display: true,
                text: 'TL Target Chart',
                position: 'bottom'
            },
            animation: {
                onComplete: () => {
                    this.drawNeedle(this.template.querySelector('.chart1').getContext('2d'),this.chart1oran);
                }
            }
        }
    };

    config2 = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [30, 40, 30],
                    backgroundColor: ['red', 'yellow', 'green'],
                    borderWidth: 0,
                    hoverBackgroundColor: ['red', 'yellow', 'green'],
                    hoverBorderWidth: 0
                }
            ]
        },
        options: {
            cutoutPercentage: 70,
            rotation: -Math.PI,
            circumference: Math.PI,
            legend: {
                display: false
            },
            tooltips: {
                enabled: false
            },
            title: {
                display: true,
                text: 'EUR Target Chart',
                position: 'bottom'
            },
            animation: {
                onComplete: () => {
                    this.drawNeedle(this.template.querySelector('.chart2').getContext('2d'),this.chart2oran);
                }
            }
        }
    };

    config3 = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [30, 40, 30],
                    backgroundColor: ['red', 'yellow', 'green'],
                    borderWidth: 0,
                    hoverBackgroundColor: ['red', 'yellow', 'green'],
                    hoverBorderWidth: 0
                }
            ]
        },
        options: {
            cutoutPercentage: 70,
            rotation: -Math.PI,
            circumference: Math.PI,
            legend: {
                display: false
            },
            tooltips: {
                enabled: false
            },
            title: {
                display: true,
                text: 'Quantity Target Chart',
                position: 'bottom'
            },
            animation: {
                onComplete: () => {
                    this.drawNeedle(this.template.querySelector('.chart3').getContext('2d'),this.chart3oran);
                }
            }
        }
    };

// İlk açılışta çalışacak işlemler burda konumlandırılır.
    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        Promise.all([
            loadScript(this, chartjs),
            loadScript(this, gaugeJS)
        ])
        .then(() => {
                const ctx1 = this.template.querySelector('.chart1').getContext('2d');
                this.chart1 = new window.Chart(ctx1, this.config1);
                const ctx2 = this.template.querySelector('.chart2').getContext('2d');
                this.chart2 = new window.Chart(ctx2, this.config2);
                const ctx3 = this.template.querySelector('.chart3').getContext('2d');
                this.chart3 = new window.Chart(ctx3, this.config3);
                this.handleClick();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Chart.js',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    
    drawNeedle(ctx,needle) {
        const width = ctx.canvas.offsetWidth;
        const height = ctx.canvas.offsetHeight;
        const needleValue = needle; // Example value, you can set this dynamically

        const angle = Math.PI * (needleValue / 100) - Math.PI;

        ctx.save();
        ctx.translate(width / 2, height - 40 );
        ctx.rotate(angle);
        ctx.beginPath();
        ctx.moveTo(0, -5);
        ctx.lineTo(height - 70, 0);
        ctx.lineTo(0, 3);
        ctx.fillStyle = 'rgba(0, 0, 0, 1)';
        ctx.fill();
        ctx.rotate(-angle);
        ctx.translate(-width / 2, -height);
        ctx.beginPath();
        ctx.arc(width / 2, height, 7, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }

    handleClick() {
        // Sadece class ile querySelector'e veri bilgisi gelmektedir.
        let saldept = this.template.querySelector('.saldept').value;
        let voption = this.template.querySelector('.voptions').value;
        let ay = this.template.querySelector('.month').value;
        let yil = this.template.querySelector('.year').value;
        searchRecords({ saldept: saldept, voption: voption, month: ay, year: yil })
        .then(result => {
                console.log(result);

                this.Actual_Amount_TL = result.ActualAmountTL1;
                this.Target_Amount_TL = result.TargetAmountTL1;
                this.Actual_Amount_EUR = result.ActualAmountEUR1;
                this.Target_Amount_EUR = result.TargetAmountEUR1;
                this.Actual_Quantity = result.ActualQuantity1;
                this.Target_Quantity = result.TargetQuantity1;

                if( result.ActualAmountTL === 0 )
                    {
                        this.chart1oran = 0;
                    }
                else if(result.TargetAmountTL === 0)
                    {
                        this.chart1oran = 100;
                    }
                else
                    {
                        this.chart1oran = result.ActualAmountTL / result.TargetAmountTL;
                    }

                if( result.ActualAmountEUR === 0 )
                    {
                        this.chart2oran = 0;
                    }
                else if(result.TargetAmountEUR === 0)
                    {
                        this.chart2oran = 100;
                    }
                else
                    {
                        this.chart2oran = result.ActualAmountEUR / result.TargetAmountEUR;
                    }
                
                if( result.ActualQuantity === 0 )
                    {
                        this.chart3oran = 0;
                    }
                else if(result.TargetQuantity === 0)
                    {
                        this.chart3oran = 100;
                    }
                else
                    {
                        this.chart3oran = result.ActualQuantity / result.TargetQuantity;
                    }

                let canvas = this.template.querySelector('.chart1');
                let ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                this.chart1 = new window.Chart(ctx, this.config1);

                canvas = this.template.querySelector('.chart2');
                ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                this.chart2 = new window.Chart(ctx, this.config2);

                canvas = this.template.querySelector('.chart3');
                ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                this.chart3 = new window.Chart(ctx, this.config3);
            })
            .catch(error => {
                console.log("Error!!!"+error.message);
            });
    }

}
