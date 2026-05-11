import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class WebsocketService {
  private socket: Socket;

  constructor() {
    // Povezuje se na NestJS gateway
    this.socket = io('http://localhost:3000'); 
  }

  // Slusamo nove podatke sa beka
  listenToMeasurements(): Observable<any> {
    return new Observable((subscriber) => {
      this.socket.on('newMeasurement', (data) => {
        subscriber.next(data);
      });
    });
  }

  listenToIncidents(): Observable<any> {
    return new Observable((subscriber) => {
      this.socket.on('newIncident', (data) => {
        subscriber.next(data);
      });
    });
  }

  listenToIncidentUpdates(): Observable<any> {
  return new Observable((subscriber) => {
    
    this.socket.on('incidentUpdated', (data) => {
      subscriber.next(data);
    });
  });
}
}