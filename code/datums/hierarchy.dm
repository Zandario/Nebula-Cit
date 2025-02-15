/decl/hierarchy
	abstract_type = /decl/hierarchy
	decl_flags = DECL_FLAG_ALLOW_ABSTRACT_INIT // for the children list
	var/name = "Hierarchy"
	var/decl/hierarchy/parent
	var/list/decl/hierarchy/children
	var/expected_type

/decl/hierarchy/Initialize()
	children = list()
	if(ispath(expected_type))
		for(var/subtype in subtypesof(type))
			var/decl/hierarchy/child = GET_DECL(subtype) // Might be a grandchild, which has already been handled.
			if(child.parent_type == type && istype(child, expected_type))
				dd_insertObjectList(children, child)
				child.parent = src
	. = ..()

/decl/hierarchy/proc/is_category()
	return INSTANCE_IS_ABSTRACT(src) && length(children)

/decl/hierarchy/proc/get_descendents()
	if(!children)
		return
	. = children.Copy()
	for(var/decl/hierarchy/child in children)
		if(child.children)
			. |= child.get_descendents()

/decl/hierarchy/dd_SortValue()
	return name
