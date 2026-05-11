import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { Store } from '@ngrx/store';

import * as SensorActions from '../../store/sensors/sensor.actions';
import * as SensorSelectors from '../../store/sensors/sensor.selector';
import { SensorUnit } from '../../core/models/sensor.model';
import { AuthService } from '../../core/services/auth';

@Component({
  selector: 'app-edit-sensor',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './edit-sensor.html',
  styleUrl: './edit-sensor.scss'
})
export class EditSensorComponent implements OnInit {

  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private store = inject(Store);
  public authService = inject(AuthService);

  id!: number;

  sensorTypes = [
    { label: 'Temperatura (C)', value: SensorUnit.CELSIUS },
    { label: 'Vlažnost (%)', value: SensorUnit.PERCENTAGE },
    { label: 'Pritisak (bar)', value: SensorUnit.BAR },
    { label: 'Napon (V)', value: SensorUnit.VOLTAGE }
  ];

  sensorData = {
    name: '',
    location: '',
    unit: '' as SensorUnit
  };

  ngOnInit() {
    this.id = Number(this.route.snapshot.paramMap.get('id'));

    this.store.dispatch(SensorActions.loadSensorById({ id: this.id }));

    this.store.select(SensorSelectors.selectSensorById(this.id))
      .subscribe(sensor => {
        if (sensor) {
          this.sensorData = {
            name: sensor.name,
            location: sensor.location,
            unit: sensor.unit
          };
        }
      });
  }

  updateSensor() {
    this.store.dispatch(
      SensorActions.updateSensor({
        id: this.id,
        sensor: this.sensorData
      })
    );

    this.router.navigate(['/sensors']);
  }

  close() {
    this.router.navigate(['/sensors']);
  }
}