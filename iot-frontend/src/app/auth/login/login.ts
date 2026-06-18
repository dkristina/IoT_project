import { ChangeDetectorRef, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router'; 
import { AuthService } from '../../core/services/auth';
import { IncidentActions } from '../../store/incident/incident.actions';
import { Store } from '@ngrx/store';
import { MatSnackBar } from '@angular/material/snack-bar';


@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  
  loginData = {
    username: '',
    password: ''
  };

  errorMessage: string = '';
  isLoading: boolean = false;

  // Injekcija zavisnosti pomocu inject() ili preko konstruktora
  private router = inject(Router);
  private store = inject(Store);
  private snackBar = inject(MatSnackBar);

  constructor(
    private authService: AuthService,
    private cdr: ChangeDetectorRef 
  ) {}

  onLogin() {
    if(!this.loginData.username || !this.loginData.password) {
      this.errorMessage = 'Molimo Vas popunite sva polja.'; 
      return; 
    }

    this.isLoading = true;
    this.errorMessage = '';

    this.authService.login(this.loginData).subscribe({
      next: (res: any) => { 
        this.isLoading = false; 
        console.log('Login uspešan!', res); 
        this.store.dispatch(IncidentActions.loadIncidents());
        // PREBACIVANJE NA DASHBOARD
        this.router.navigate(['/dashboard']); 
      },
      error: (err: any) => {
        this.isLoading = false;
        
        if (err.status === 401) {
          this.errorMessage = 'Pogrešno korisničko ime ili lozinka.';
        } else {
          this.errorMessage = 'Greška na serveru. Proverite da li je Backend pokrenut.';
        }
        
        console.error('Greška pri prijavi:', err);
        this.cdr.detectChanges(); 
      }
    });
  }

  onForgotPassword() {
    // 🚀 Избачен ружни alert(), додат прелепи SnackBar
    this.snackBar.open('Obratite se administratoru za reset lozinke.', 'Zatvori', {
      duration: 4000,
      horizontalPosition: 'center',
      verticalPosition: 'bottom',
      panelClass: ['modern-snackbar'] // Ово ти омогућава да у CSS-у лако обојиш позадину
    });
  }
}