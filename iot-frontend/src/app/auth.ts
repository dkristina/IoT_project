import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AuthService {

  //putanja do back-a
  private apiUrl = 'http://localhost:3000/auth/login';

  constructor(private http: HttpClient){}

  login(credentials: any) : Observable<any> {
    //saljemo post zahtev na backend
    return this.http.post(this.apiUrl, credentials); 
  }
}
