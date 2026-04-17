import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Measurement } from '../models/measurement.model';

@Injectable({
  providedIn: 'root'
})
export class MeasurementsService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:3000/measurements';

  
  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  // 1. Dobijanje svih merenja (GET /measurements)
  // Korisno za globalnu statistiku na dashboardu
  findAll(): Observable<Measurement[]> {
    return this.http.get<Measurement[]>(this.apiUrl, { headers: this.getHeaders() });
  }

  // 2. Dobijanje jednog specificnog merenja (GET /measurements/:id)
  findOne(id: number): Observable<Measurement> {
    return this.http.get<Measurement>(`${this.apiUrl}/${id}`, { headers: this.getHeaders() });
  }

  // 3. Kreiranje novog merenja (POST /measurements)
  create(measurementData: Partial<Measurement>): Observable<Measurement> {
    return this.http.post<Measurement>(this.apiUrl, measurementData, { headers: this.getHeaders() });
  }
}