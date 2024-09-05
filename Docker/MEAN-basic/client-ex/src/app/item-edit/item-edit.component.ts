import { Component, OnInit } from '@angular/core';
import { NoteService } from '../services/item.service';
import { ActivatedRoute, Router } from '@angular/router';
import {
  ReactiveFormsModule,
  FormGroup,
  FormBuilder,
  Validators,
} from '@angular/forms';
import { CommonModule } from '@angular/common';
import { NoteType } from '../services/models';

@Component({
  selector: 'app-item-edit',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './item-edit.component.html',
  styleUrls: ['./item-edit.component.scss'],
})
export class NoteEditComponent implements OnInit {
  editForm: FormGroup;
  id: string;

  constructor(
    private noteService: NoteService,
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router
  ) {
    this.editForm = this.fb.group({
      title: ['', Validators.required],
      content: ['', Validators.required],
    });
    this.id = this.route.snapshot.params['id'];
  }

  ngOnInit(): void {
    this.noteService.getNote(this.id).subscribe((data: NoteType) => {
      this.editForm.setValue({
        title: data.title,
        content: data.content,
      });
    });
  }

  onSubmit(): void {
    if (this.editForm.valid) {
      this.noteService
        .updateNote(this.id, this.editForm.value)
        .subscribe(() => {
          this.router.navigate(['/']);
        });
    }
  }

  onReturn(): void {
    this.router.navigate(['/']);
  }
}
