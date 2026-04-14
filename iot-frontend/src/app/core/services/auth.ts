import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private http = inject(HttpClient);
  // Putanja do tvog login endpoint-a na backendu
  private apiUrl = 'http://localhost:3000/auth/login';

  login(credentials: any): Observable<any> {
    // saljemo post zahtev sa username i password
    return this.http.post(this.apiUrl, credentials).pipe(
      tap((res: any) => {
        // Automatski cuvamo token cim stigne sa servera
        if (res && res.access_token) {
          localStorage.setItem('access_token', res.access_token);
        }
      })
    );
  }

  // Pomocna metoda za logout
  logout() {
    localStorage.removeItem('access_token');
  }
}