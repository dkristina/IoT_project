import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({
  providedIn: 'root'
})
export class UsersService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:3000/users';

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  // 1. Dobijanje svih korisnika (ADMIN i OPERATOR)
  findAll(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl, { headers: this.getHeaders() });
  }

  // 2. Dobijanje samo operatera (korisno za dodelu incidenata)
  findOperators(): Observable<User[]> {
    return this.http.get<User[]>(`${this.apiUrl}/operators`, { headers: this.getHeaders() });
  }

  // 3. Pretraga korisnika po imenu (GET /users/search?name=...)
  searchByName(name: string): Observable<User[]> {
    const params = new HttpParams().set('name', name);
    return this.http.get<User[]>(`${this.apiUrl}/search`, { 
      headers: this.getHeaders(), 
      params 
    });
  }

  // 4. Dobijanje jednog korisnika po ID-u
  findOne(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`, { headers: this.getHeaders() });
  }

  // 5. Azuriranje profila (ADMIN ili Vlasnik profila)
  update(id: number, userData: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.apiUrl}/${id}`, userData, { headers: this.getHeaders() });
  }

  // 6. Kreiranje korisnika (Samo ADMIN)
  create(userData: Partial<User>): Observable<User> {
    return this.http.post<User>(this.apiUrl, userData, { headers: this.getHeaders() });
  }

  // 7. Brisanje korisnika (Samo ADMIN)
  remove(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`, { headers: this.getHeaders() });
  }
}