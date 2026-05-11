import { Component, EventEmitter, Output, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SensorsService } from '../../core/services/sensor.service';
import { SensorUnit } from '../../core/models/sensor.model';
import { Router } from '@angular/router'; // Dodaj Router
import { AuthService } from '../../core/services/auth';

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
    unit: '' as SensorUnit
  };

  ngOnInit() {
    // OGRANIČENJE: Ako nije admin, vrati ga nazad i ne daj mu da vidi formu
    if (!this.authService.isAdmin()) {
      this.onCancel();
    }
  }

  onSubmit() {
    if (!this.sensorData.name || !this.sensorData.location || !this.sensorData.unit) return;

    this.sensorsService.createSensor(this.sensorData).subscribe({
      next: (response) => {
        // 1. Javi listi da se osveži
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