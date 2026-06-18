import { Component, Inject, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-manual-incident-dialog',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule
  ],
  template: `
    <div class="custom-dialog-container">
      <div class="dialog-header">
        <mat-icon class="header-icon">report_problem</mat-icon>
        <h2>Ručno prijavljivanje incidenta</h2>
      </div>

      <mat-dialog-content>
        <div class="warning-box" *ngIf="data.hasActiveIncident">
          <div class="warning-header">
            <mat-icon>warning</mat-icon>
            <span>Warning: An active incident already exists for this sensor.</span>
          </div>
          <p>Do you want to create an additional manual incident?</p>
        </div>

        <p class="instruction-text">Unesite opis problema koji ste uočili na senzoru:</p>
        
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Opišite problem</mat-label>
          <textarea matInput [(ngModel)]="description" rows="4" placeholder="Npr. Vrednosti na terenu ne odgovaraju onima na grafiku..."></textarea>
        </mat-form-field>
      </mat-dialog-content>

      <mat-dialog-actions align="end">
        <button mat-button class="btn-cancel" (click)="onCancel()">Otkaži</button>
        <button mat-raised-button class="btn-confirm" 
                [disabled]="!description.trim()" 
                (click)="onConfirm()">
          <mat-icon>check</mat-icon> Potvrdi i kreiraj
        </button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .custom-dialog-container {
      background: #161f2e; /* Ista tamno plava kao tvoja tabela i kontrolna tabla */
      color: white;
      padding: 1rem;
      border-radius: 20px;
    }
    .dialog-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 1.5rem;
      h2 { margin: 0; color: white; font-size: 1.35rem; font-weight: 600; }
      .header-icon { color: #ef4444; font-size: 28px; width: 28px; height: 28px; }
    }
    .warning-box {
      background: rgba(245, 158, 11, 0.15);
      border: 1px solid rgba(245, 158, 11, 0.4);
      padding: 1rem;
      border-radius: 14px;
      margin-bottom: 1.5rem;
      .warning-header {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #f59e0b;
        font-weight: 700;
        font-size: 0.95rem;
        mat-icon { font-size: 20px; width: 20px; height: 20px; }
      }
      p { color: #cbd5e1; margin: 0.5rem 0 0 0; font-size: 0.9rem; font-weight: 500; }
    }
    .instruction-text { color: #9ca3af; font-size: 0.9rem; margin-bottom: 0.5rem; }
    .full-width {
      width: 100%;
      ::v-deep .mat-mdc-text-field-wrapper { background-color: #0f172a !important; }
      ::v-deep textarea { color: white !important; }
      ::v-deep .mat-mdc-form-field-subscript-sizing { display: none; }
    }
    mat-dialog-actions { gap: 10px; margin-top: 1rem; }
    .btn-cancel { color: #9ca3af; &:hover { background: rgba(255, 255, 255, 0.05); } }
    .btn-confirm {
      background-color: #3b82f6 !important;
      color: white !important;
      font-weight: 600;
      border-radius: 10px;
      &:disabled { background-color: #334155 !important; color: #64748b !important; }
    }
  `]
})
export class ManualIncidentDialogComponent {
  private dialogRef = inject(MatDialogRef<ManualIncidentDialogComponent>);
  description: string = '';

  constructor(@Inject(MAT_DIALOG_DATA) public data: { hasActiveIncident: boolean }) {}

  onCancel(): void {
    this.dialogRef.close(null);
  }

  onConfirm(): void {
    if (this.description.trim()) {
      this.dialogRef.close({ description: this.description });
    }
  }
}