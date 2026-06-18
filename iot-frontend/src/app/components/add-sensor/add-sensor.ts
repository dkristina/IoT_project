import { Component, EventEmitter, Output, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SensorsService } from '../../core/services/sensor.service';
import { SensorUnit } from '../../core/models/sensor.model';
import { Router } from '@angular/router'; // Dodaj Router
import { AuthService } from '../../core/services/auth';
import { AlarmSeverity } from '../../core/models/alarm.model';

@Component({
  selector: 'app-add-sensor',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-sensor.html',
  styleUrl: './add-sensor.scss'
})
export class AddSensorComponent {
  private sensorsService = inject(SensorsService);
  private router = inject(Router); // Inject-uj ruter
  public authService = inject(AuthService);
  
  @Output() closeModal = new EventEmitter<void>();
  @Output() sensorAdded = new EventEmitter<void>();

  sensorData = {
    name: '',
    location: '',
    unit: '' as SensorUnit,
    alarms: [] as Array<{ severity: AlarmSeverity; lowThreshold: number | null; highThreshold: number | null }>
  };

  ngOnInit() {
    // OGRANICENJE: Ako nije admin, vrati ga nazad i ne daj mu da vidi formu
    if (!this.authService.isAdmin()) {
      this.onCancel();
    }
    this.addRule(); 
  }

  addRule() {
    if (this.sensorData.alarms.length >= 4) return;
    this.sensorData.alarms.push({
      severity: AlarmSeverity.CRITICAL, 
      lowThreshold: 0,
      highThreshold: 0
    });
  }
  removeRule(index: number) {
    this.sensorData.alarms.splice(index, 1);
  }
  onSubmit() {
    if (!this.sensorData.name || !this.sensorData.location || !this.sensorData.unit) return;

    const formattedAlarms = this.sensorData.alarms.map(alarm => ({
    severity: alarm.severity,
    lowThreshold: Number(alarm.lowThreshold),  
    highThreshold: Number(alarm.highThreshold) 
  }));


    const payload = {
      name: this.sensorData.name,
      location: this.sensorData.location,
      unit: this.sensorData.unit,
      alarms: this.sensorData.alarms 
    };

    this.sensorsService.createSensor(payload as any).subscribe({
      next: (response) => {
        // 1. Javi listi da se osvezi
        this.sensorAdded.emit(); 
        // 2. Zatvori modal
        this.closeModal.emit();
        // 3. Vrati korisnika na listu senzora
        this.router.navigate(['/sensors']);
      },
      error: (err) => alert("Greška: " + err.message)
    });
  }

  onCancel() {
    
    this.router.navigate(['/sensors']);
    this.closeModal.emit();
  }
}