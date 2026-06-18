import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Sensor } from '../models/sensor.model';

@Injectable({
  providedIn: 'root'
})
export class SensorsService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:3000/sensors';

  /*
  // Pomocna metoda za kreiranje zaglavlja sa tokenom
  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }*/

  // 1. Dobijanje svih senzora (GET) 
  getSensors(): Observable<Sensor[]> {
    return this.http.get<Sensor[]>(this.apiUrl);
  }

  // 2. Dobijanje jednog senzora sa merenjima (GET /sensors/:id)
  getSensorById(id: number): Observable<Sensor> {
    return this.http.get<Sensor>(`${this.apiUrl}/${id}`);
  }

  // 3. Kreiranje novog senzora (POST) - Samo za ADMIN-a na backendu
  createSensor(sensorData: any): Observable<Sensor> {
    return this.http.post<any>(this.apiUrl, sensorData);
  }

  // 4. Azuriranje senzora (PATCH /sensors/:id)
  updateSensor(id: number, sensorData: Partial<Sensor>): Observable<Sensor> {
    return this.http.patch<Sensor>(`${this.apiUrl}/${id}`, sensorData);
  }

  // 5. Brisanje senzora (DELETE /sensors/:id)
  deleteSensor(id: number): Observable<{ message: string }> {
    return this.http.delete<{ message: string }>(`${this.apiUrl}/${id}`);
  }
}