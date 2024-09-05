import { Routes } from '@angular/router';
import { NoteListComponent } from './item-list/item-list.component';
import { NoteCreateComponent } from './item-create/item-create.component';
import { NoteEditComponent } from './item-edit/item-edit.component';

export const routes: Routes = [
  { path: '', component: NoteListComponent },
  { path: 'create', component: NoteCreateComponent },
  { path: 'edit/:id', component: NoteEditComponent },
];
