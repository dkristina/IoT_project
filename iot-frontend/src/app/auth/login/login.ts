import { ChangeDetectorRef, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../auth';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  // Objekat u koji ce se smestati podaci iz forme
  loginData = {
    username: '',
    password: ''
  };

  errorMessage: string = '';
  isLoading: boolean = false;

  constructor(
    private authService: AuthService,
    private cdr: ChangeDetectorRef 
  ) {}

  // Metoda koja se poziva kada korisnik klikne na dugme "Prijavi se"
  onLogin() {

    if(!this.loginData.username || !this.loginData.password )
    {
      this.errorMessage = 'Molimo Vas popunite sva polja.'; 
      return; 
    }

    this.isLoading = true;
    this.errorMessage = '';

    this.authService.login(this.loginData).subscribe({
      next: (res) => {
        this.isLoading = false; 
        console.log('Backend je prihvatio login!', res); 

        //cuvam token koji nam je vratio auth service sa back-a
        localStorage.setItem('token', res.access_token); 

        alert('Successfull! Welcome: ' + res.user.fullName); 
      },
      error: (err) => {
        this.isLoading = false;
        
        if (err.status === 401) {
          this.errorMessage = 'Pogrešno korisničko ime ili lozinka.';
        } else if (err.status === 404) {
          this.errorMessage = 'Server ne prepoznaje rutu. Proveri backend.';
        } else {
          this.errorMessage = 'Došlo je do greške na serveru. Pokušajte kasnije.';
        }
        console.error('Greška pri prijavi:', err);
        this.cdr.detectChanges();
      }
    })
  }

  onForgotPassword() {
    alert('Funkcija za oporavak lozinke!');
  }
}