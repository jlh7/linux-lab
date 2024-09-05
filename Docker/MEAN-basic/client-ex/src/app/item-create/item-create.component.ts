import { Component } from '@angular/core';
import { NoteService } from '../services/item.service';
import { Router } from '@angular/router';
import {
  ReactiveFormsModule,
  FormGroup,
  FormBuilder,
  Validators,
} from '@angular/forms';

@Component({
  selector: 'app-item-create',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './item-create.component.html',
  styleUrls: ['./item-create.component.scss'],
})
export class NoteCreateComponent {
  createForm: FormGroup;

  constructor(
    private noteService: NoteService,
    private fb: FormBuilder,
    private router: Router
  ) {
    this.createForm = this.fb.group({
      title: ['', Validators.required],
      content: ['', Validators.required],
    });
  }

  onSubmit(): void {
    if (this.createForm.valid) {
      this.noteService.createNote(this.createForm.value).subscribe(() => {
        this.router.navigate(['/']);
      });
    }
  }

  onReturn(): void {
    this.router.navigate(['/']);
  }
}
