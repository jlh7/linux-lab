import { Component } from '@angular/core';
import { NoteService } from '../services/item.service';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { interval } from 'rxjs';
import { NoteType } from '../services/models';

@Component({
  selector: 'app-item-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './item-list.component.html',
  styleUrls: ['./item-list.component.scss'],
})
export class NoteListComponent {
  notes: NoteType[] = [];

  constructor(private noteService: NoteService, private router: Router) {}

  ngOnInit(): void {
    this.fetchNotes();
    interval(1000).subscribe(() => {
      this.fetchNotes();
    });
  }

  fetchNotes(): void {
    this.noteService.getNotes().subscribe((data: NoteType[]) => {
      this.notes = data;
    });
  }

  deleteNote(id: string): void {
    this.noteService.deleteNote(id).subscribe(
      () => {
        this.notes = this.notes.filter((note) => note.id !== id);
      },
      (error: any) => {
        console.error('Error deleting note:', error);
        alert('Could not delete note. Please try again later.');
      }
    );
  }

  editNote(id: any): void {
    this.router.navigate([`/edit/${id}`]);
  }
}
