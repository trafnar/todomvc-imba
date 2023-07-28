import {nanoid} from 'nanoid'
const {log} = console

def buildTodo properties = {}
	if properties.text != null
		properties.text = properties.text.trim()
		return {id: nanoid(), text: "Untitled", completed: false, ...properties}

# this is all standard Javascript written with Imba syntax
# there aren't any special Imba features being used to deal with state
# this could actually be rewritten as Javascript and imported into TodoMVC.imba just the same

export class TodoMVCState
	prop todos = []
	prop currentFilter = null

	constructor
		todos = load() ?? []

	def updateTodo todo, properties = {}
		todos.map do(t) if t.id == todo.id then {...t, ...properties} else t
	
	def filteredTodos
		return complete() if currentFilter === "completed"
		return remaining() if currentFilter === "active"
		return todos
	
	def setFilter filter
		currentFilter = if filter === "completed" or filter === "active" then filter else null
	
	def remaining
		log todos
		todos.filter do(t) !t.completed
	def complete do todos.filter do(t) t.completed

	def toggleTodo todo
		save do
			updateTodo(todo, {completed: !todo.completed})

	def deleteTodo todo
		save do todos.filter do(t) t.id != todo.id

	def editTodo todo, text
		save do updateTodo(todo, {text})

	def clearComplete
		save do todos.filter do(t) !t.completed

	def addTodo text
		save(do [...todos, buildTodo({text})]) unless text.trim().length === 0

	def setAll completed
		save do todos.map do(t) {...t, completed}
	
	# wrap this around operations to save the state and persist
	def save fn
		todos = fn()
		persist(todos)
	
	def persist todos
		todos.map do(todo) { text: todo.text, completed: todo.completed }
		window.localStorage.setItem("todos-imba", JSON.stringify(todos))

	def load
		const raw = window.localStorage.getItem("todos-imba")
		try JSON.parse(raw) ?? []
		catch e return []


