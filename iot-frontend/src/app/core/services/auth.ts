import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, tap } from 'rxjs';
import { User } from '../models/user.model'; 
import { Router } from '@angular/router';

//opisuje kako backend odgovara na login 
interface LoginResponse {
  access_token: string;
  user: User;
}

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:3000/auth/login';
  private router = inject(Router);
  
  // BehaviorSubject koji cuva trenutnog korisnika
  // Na početku je null, a kasnije dobija podatke
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  
  // Observable koji ce komponente "slušati"
  currentUser$ = this.currentUserSubject.asObservable();

  constructor() {
    this.checkUserStatus();
    
  }

  // Provera pri osvezavanju stranice (F5)
  private checkUserStatus() {
    const token = localStorage.getItem('access_token');
    const userData = localStorage.getItem('user_data');
    
    if (token && userData) {
      // Ako imamo i token i sacuvane podatke, samo ih emitujemo u tok
      this.currentUserSubject.next(JSON.parse(userData));
    }
  }

  login(credentials: { username: string; password: string }): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(this.apiUrl, credentials).pipe(
      tap((res) => {
        if (res && res.access_token) {
          localStorage.setItem('access_token', res.access_token);
          
          //backend vec vraca lep 'user' objekat (fullName, role, itd.)
          //Bolje je da sacuvamo njega
          const userData = res.user;
          localStorage.setItem('user_data', JSON.stringify(userData));
          
          // Emitujemo podatke kroz BehaviorSubject
          this.currentUserSubject.next(userData);
        }
      })
    );
  }

  // Logout metoda
  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('user_data');
    this.currentUserSubject.next(null);
    
    this.router.navigate(['/login']);
  }

  // Pomocna metoda za proveru uloge (trebace nam za sakrivanje dugmica)
  hasRole(role: string): boolean {
    const user = this.currentUserSubject.value;
    return user ? user.role === role : false;
  }

  isLoggedIn(): boolean {
    return !!this.currentUserSubject.value; 
  }

  isAdmin(): boolean {
    return this.hasRole('ADMIN'); 
  }

  isOperator(): boolean {
    return this.hasRole('OPERATOR'); 
  }

  // 1. Pomocna metoda da lako dobijemo trenutne podatke bez "pretplate"
getCurrentUserValue(): User | null {
  return this.currentUserSubject.value;
}

// 2. Metoda za azuriranje profila (slika, email, itd.)
updateProfile(userId: number, data: any): Observable<User> {
  const usersApiUrl = `http://localhost:3000/users/${userId}`;
  
  
  return this.http.patch<User>(usersApiUrl, data).pipe(
    tap((updatedUser) => {
      // Azuriramo lokalnu kopiju i emitujemo nove podatke (email, sliku itd.)
      localStorage.setItem('user_data', JSON.stringify(updatedUser));
      this.currentUserSubject.next(updatedUser);
    })
  );
}
}