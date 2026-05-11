import { Component, EventEmitter, inject, Input, Output } from "@angular/core";
import { AuthService } from "../../core/services/auth";


@Component({
  selector: 'app-alarm-filter',
  standalone: true,
  template: `
    <div class="filter-box">
      <label>{{ labela }}</label>
      <input 
        type="number" 
        [placeholder]="placeholderText"
        (input)="onSearch($event)"
      >
    </div>
  `,
  styles: [`
    .filter-box { 
      margin-bottom: 25px; 
      padding: 15px; 
      background: #161f2e; /* Tamna pozadina kao na dashboardu */
      border: 1px solid #1f2937;
      border-radius: 12px;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    label {
      color: #9ca3af;
      font-size: 13px;
      text-transform: uppercase;
      font-weight: 600;
    }
    input {
      background: #0b111e;
      border: 1px solid #374151;
      color: white !important; /* Bela slova dok kucaš */
      padding: 10px 15px;
      border-radius: 8px;
      outline: none;
      font-size: 14px;
      
      &:focus { border-color: #3b82f6; }
      &::placeholder { color: rgba(255, 255, 255, 0.3); }
    }
  `]
})

export class AlarmFilterComponent {
  public authService = inject(AuthService);
  

  @Input() labela: string = 'Pretraga:';
  @Input() placeholderText: string = 'Unesite ID senzora...';

  @Input() adminOnly: boolean = false;

  @Output() filterChanged = new EventEmitter<number>();


  shouldShow(): boolean {
    if (this.adminOnly) {
      return this.authService.isAdmin();
    }
    // Ako nije adminOnly, znaci da je obican findAll/findOne pretraga koju sme i Operater
    return true; 
  }
  onSearch(event: any) {
    const value = event.target.value;
    this.filterChanged.emit(Number(value));
  }
}