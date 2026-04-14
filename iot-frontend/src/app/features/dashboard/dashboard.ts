import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';

import { Sensor } from '../../core/models/sensor.model';
import { SensorsService } from '../../core/services/sensor.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.scss'
})
export class DashboardComponent implements OnInit {
  private sensorsService = inject(SensorsService);
  private cdr = inject(ChangeDetectorRef);
  
  sensors: Sensor[] = [];
  isLoading: boolean = true;

  ngOnInit() {
    this.loadSensors();
  }

  loadSensors() {
    this.sensorsService.getSensors().subscribe({
      next: (data) => {
        this.sensors = data;
        this.isLoading = false;

        this.sensors.forEach((sensor, index) => {
            this.sensorsService.getSensorById(sensor.id).subscribe({
                next: (detailedSensor: any) => {
                    //ubacujemo merenja u originalni objekat u nizu 
                    this.sensors[index].measurements = detailedSensor.measurements;
                    
                    this.cdr.detectChanges(); 
                }
            });
        });
        console.log('Senzori učitani:', this.sensors);
        
      },
      error: (err) => {
        console.error('Greška pri učitavanju senzora:', err);
        this.isLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  onDelete(id: number) {
  if (confirm('Da li ste sigurni da želite da obrišete ovaj senzor?')) {
    this.sensorsService.deleteSensor(id).subscribe({
      next: () => {
        // Osvežavamo listu tako što izbacimo obrisani senzor iz niza
        this.sensors = this.sensors.filter(s => s.id !== id);
        this.cdr.detectChanges();
      },
      error: (err) => alert('Greška pri brisanju: Verovatno niste ADMIN ili senzor ima povezana merenja.')
    });
  }
}
    onAddSensor() {
  // Za početak samo jedan alert, dok ne napravimo formu
  alert('Otvaram formu za novi senzor...');
}

}