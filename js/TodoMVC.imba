

export tag TodoMVC

	prop todos = [
		{text: "Taste JavaScript", completed: true, editing: false},
		{text: "Buy a unicorn", completed: false, editing: false},
	]

	prop filter = null

	def setup
		todos = load()
	
	def mount
		router.on "hashchange" do doRouting()
		doRouting()
	
	def doRouting
		filter = router.hash.replace("#/", "").trim()
		render()
	
	def getFilteredTodos
		return getRemaining() if filter === "active"
		return getCompleted() if filter === "completed"
		return todos
	
	def persist todos
		todos.map do(todo) { text: todo.text, completed: todo.completed, editing: false }
		window.localStorage.setItem("todos-imba", JSON.stringify(todos))

	def load
		const raw = window.localStorage.getItem("todos-imba")
		try JSON.parse(raw) ?? []
		catch e return []

	prop newTodoText = ""

	def getRemaining do todos.filter(do(todo) !todo.completed)
	def getCompleted do todos.filter(do(todo) todo.completed)

	def setAll to\boolean do todo.completed = to for todo in todos
	def updateToggleAll do $toggleAll.checked = todos.length > 0 and getRemaining().length === 0
	
	def clearCompleted
		todos = todos.filter(do(todo) !todo.completed)
		updateToggleAll()
	
	def deleteTodoByIndex index
		todos.splice(index, 1)
		updateToggleAll()
		
	def addNewTodo
		const trimmed = newTodoText.trim()
		return if trimmed.length === 0
		todos.push { text: trimmed, completed:false, editing: false }
		newTodoText = ""
		persist(todos)
	
	def handleToggle todo
		todo.completed = !todo.completed
		persist(todos)
		updateToggleAll()

	def startEdit todo, i
		for todo in todos
			todo.editing = false
			todo.editHistory = null
		todo.editHistory = todo.text
		todo.editing = true
		render()
		self.querySelector("#todo-{i}-input").focus()
	
	def abortEdit todo
		todo.text = todo.editHistory
		todo.editHistory = null
		todo.editing = false

	def commitEdit todo, i
		const trimmed = todo.text.trim()
		if trimmed.length === 0
			deleteTodoByIndex(i)
		else
			todo.text = trimmed
			todo.editHistory = null
			todo.editing = false
		persist(todos)
	
	<self>
		const remaining = getRemaining()
		const completed = getCompleted()
		<section.todoapp>
			<header.header>
				<h1> "todos"
				<form @submit.log('hi').prevent=addNewTodo(newTodoText)>
					<input bind=newTodoText .new-todo placeholder="What needs to be done?" autofocus>

			if todos.length > 0
				# This section should be hidden by default and shown when there are todos
				<section.main>

					<input$toggleAll id="toggle-all" .toggle-all type="checkbox" @change=setAll(e.target.checked)>
					<label for="toggle-all"> "Mark all as complete"

					<ul.todo-list>
						# These are here just to show the structure of the list items
						# List items should get the class `editing` when editing and `completed` when marked as completed
						for todo, i in getFilteredTodos()
							<li key=todo .completed=todo.completed .editing=todo.editing>
								<div.view>
									<input.toggle @change=handleToggle(todo) type="checkbox" checked=todo.completed>
									<label @dblclick=startEdit(todo, i)> todo.text
									<button.destroy @click=deleteTodoByIndex(i)>

								<form @submit.prevent=commitEdit(todo,i)>	
									<input.edit
										bind=todo.text
										@blur=commitEdit(todo, i)
										@hotkey('escape').if(todo.editing).force=abortEdit(todo)
										id="todo-{i}-input"
									>
						
			
			if todos.length > 0
				# This footer should be hidden by default and shown when there are todos
				<footer.footer>
					# This should be `0 items left` by default
					<span.todo-count> "{<strong> remaining.length} item{if remaining.length === 1 then "" else "s"} left"
					
					# Remove this if you don't implement routing
					<ul.filters>
						<li> <a .selected=(filter !== "completed" and filter !== "active") route-to="/"> "All"
						<li> <a route-to="#/active" .selected=(filter === "active")> "Active"
						<li> <a route-to="#/completed" .selected=(filter === "completed")> "Completed"
					
					# Hidden if no completed items are left ↓
					if completed.length > 0
						<button.clear-completed @click=clearCompleted> "Clear completed"

		<footer.info>
			<p> "Double-click to edit a todo"
			
			# Change this out with your name and url ↓
			<p> "Created by {<a href="https://www.nathanmanousos.com"> "Nathan Manousos"}"
			<p> "Part of {<a href="http://todomvc.com"> "TodoMVC"}"	
