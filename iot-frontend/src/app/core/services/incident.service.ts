import { HttpClient, HttpHeaders } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { Incident, IncidentStatus } from "../models/incident.model";

@Injectable({
  providedIn: 'root'
})

export class IncidentService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:3000/incidents';

  /*
  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }*/

  // 1. Dobijanje svih incidenata
  findAll(): Observable<Incident[]> {
    return this.http.get<Incident[]>(this.apiUrl);
  }

  // 2. Dobijanje jednog incidenta (GET /incidents/:id)
  findOne(id: number): Observable<Incident> {
    return this.http.get<Incident>(`${this.apiUrl}/${id}`);
  }

  // 3. Kreiranje incidenta (POST /incidents)
  create(incidentData: Partial<Incident>): Observable<Incident> {
    return this.http.post<Incident>(this.apiUrl, incidentData);
  }

  // 4. Azuriranje incidenta (PATCH /incidents/:id)
  update(id: number, incidentData: Partial<Incident>): Observable<Incident> {
    return this.http.patch<Incident>(`${this.apiUrl}/${id}`, incidentData);
  }

  // 5. Brisanje incidenta (DELETE /incidents/:id)
  remove(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }

  //pomocna metoda
  takeIncident(incidentId: number, userId: number): Observable<Incident> {
    const changes = {
      assignedToId: userId,
      status: IncidentStatus.IN_PROGRESS
    };
    return this.update(incidentId, changes as any);
  }

  findBySensor(sensorId: number): Observable<Incident[]> {
    return this.http.get<Incident[]>(`${this.apiUrl}/sensor/${sensorId}`);
  }
}