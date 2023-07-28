import { TodoMVCState } from './TodoMVCState'

# This is the model/state of the app. It works fine as a standard variable here
# it could also be added as a prop on the TodoMVC tag or made available to all tags
# by extending the element tag: `extend tag element`
const state = new TodoMVCState()

def pluralize n, s do  if n === 1 then s else s + "s"

export tag TodoMVC

	prop newTodoText = ""

	def handleAddTodo
		state.addTodo(newTodoText)
		newTodoText = ""
	
	def mount
		# start listening for route changes
		router.on "hashchange" do doRouting()
		doRouting()
	
	def doRouting
		state.setFilter router.hash.replace("#/", "").trim()
		render()
	
	def rendered
		# update complete all checkbox state
		$toggleAll.checked = state.remaining().length === 0 and state.todos.length > 0

	<self>
		<section.todoapp>
			<header.header>
				<h1> "todos"
				<form @submit.prevent=handleAddTodo>
					<input bind=newTodoText .new-todo placeholder="What needs to be done?" autofocus>

			if state.todos.length > 0
				# This section should be hidden by default and shown when there are todos
				<section.main>

					<input$toggleAll id="toggle-all" .toggle-all type="checkbox" @change=state.setAll($toggleAll.checked)>
					<label for="toggle-all"> "Mark all as complete"

					<ul.todo-list>
						# These are here just to show the structure of the list items
						# List items should get the class `editing` when editing and `completed` when marked as completed
						for todo, i in state.filteredTodos()
							<Todo
								key=todo.id
								bind:text=todo.text
								completed=todo.completed
								@toggle=state.toggleTodo(todo)
								@delete=state.deleteTodo(todo)
							>
			
			if state.todos.length > 0
				# This footer should be hidden by default and shown when there are todos
				<footer.footer>
					# This should be `0 items left` by default
					<span.todo-count> "{state.remaining().length} {<strong> pluralize(state.remaining().length, "item" )} left"
					
					# Remove this if you don't implement routing
					<ul.filters>
						<li> <a .selected=( state.currentFilter == null ) route-to="/"> "All"
						<li> <a route-to="#/active" .selected=(state.currentFilter === "active")> "Active"
						<li> <a route-to="#/completed" .selected=(state.currentFilter === "completed")> "Completed"
					
					# Hidden if no completed items are left ↓
					if state.complete().length > 0
						<button.clear-completed @click=state.clearComplete()> "Clear completed"

		<footer.info>
			<p> "Double-click to edit a todo"
			
			# Change this out with your name and url ↓
			<p> "Created by {<a href="https://www.nathanmanousos.com"> "Nathan Manousos"}"
			<p> "Part of {<a href="http://todomvc.com"> "TodoMVC"}"	



tag Todo < li

	prop completed = false
	prop text = "Untitled"
	prop editing = false
	prop draftText = ""

	def startEdit
		draftText = text
		editing = true
	
	def commitEdit
		text = draftText
		draftText = ""
	
	def abortEdit
		draftText = ""

	<self .completed=completed .editing=editing>
		<div.view>
			<input.toggle @change.emit('toggle') type="checkbox" checked=completed>
			<label @dblclick=startEdit> text
			<button.destroy @click.emit('delete')>

		<form @submit.prevent=commitEdit>	
			<input.edit
				bind=draftText
				@blur=commitEdit
				@hotkey('escape').if(editing).force=abortEdit
			>
