import { Component, EventEmitter, Output, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { UserRole } from '../../core/models/user.model'; // Proveri putanju do enuma
import { AuthService } from '../../core/services/auth';

@Component({
  selector: 'app-user-modal',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './user-modal.html',
  styleUrl: './user-modal.scss'
})
export class UserModalComponent {
  public authService = inject(AuthService);

  @Input() isOpen = false;
  @Output() close = new EventEmitter<void>();
  @Output() save = new EventEmitter<any>();

  userForm: FormGroup;
  errorMessage: string = '';

  constructor(private fb: FormBuilder) {
    this.userForm = this.fb.group({
      fullName: ['', Validators.required],
      username: ['', [Validators.required]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      role: [UserRole.OPERATOR, Validators.required]
    });
  }

  onClose() {
    this.errorMessage = '';
    this.userForm.reset({ role: UserRole.OPERATOR });
    this.close.emit();
  }

  submit() {
    if (this.userForm.valid) {
      
      this.save.emit(this.userForm.value);
      this.onClose();
    } else {
      this.errorMessage = 'Molimo ispunite sva polja ispravno.';
    }
  }
}