module ToDoListTest

test pointToggleTest {
	//Basic test to check if point can be toggled
  var p := Point{ name := "test" };
  assert(p.done == false);
  p.toggleDone();
  assert(p.done == true);
  p.toggleDone();
  assert(p.done == false);
}

test deleteList {
	//Test the delete list function
	var owner:= User{name := "owner"};
	var writer:= User{name := "writer"};
	var reader:= User{name := "reader"};
	var list:= PointList{name := "TestList" owner := owner};
	list.writer.add(writer);
	list.reader.add(reader);
	owner.ownerList.add(list);
	writer.writeList.add(list);
	reader.readList.add(list);
	assert(list.owner == owner);
	assert(writer in list.writer);
	assert(reader in list.reader);
	assert(list in owner.ownerList);
	assert(list in writer.writeList);
	assert(list in reader.readList);
	deleteList(list,owner); // What we test
	assert(!(list.owner == owner));
	assert(!(writer in list.writer));
	assert(!(reader in list.reader));
	assert(!(list in owner.ownerList));
	assert(!(list in writer.writeList));
	assert(!(list in reader.readList));
}

test leaveListAsWriter{
	//Test the leave list function
	//When user with writer access leaves
	var owner:= User{name := "owner"};
	var writer:= User{name := "writer"};
	var list:= PointList{name := "TestList" owner := owner};
	list.writer.add(writer);
	owner.ownerList.add(list);
	writer.writeList.add(list);
	assert(list.owner == owner);
	assert(writer in list.writer);
	assert(list in owner.ownerList);
	assert(list in writer.writeList);
	leaveList(list,writer,true); // What we test
	assert(list.owner == owner);
	assert(!(writer in list.writer));
	assert((list in owner.ownerList));
	assert(!(list in writer.writeList));
}

test leaveListAsReader{
	// Test the leave list function
	// When user with reader access leaves
	var owner:= User{name := "owner"};
	var reader:= User{name := "reader"};
	var list:= PointList{name := "TestList" owner := owner};
	list.reader.add(reader);
	owner.ownerList.add(list);
	reader.readList.add(list);
	assert(list.owner == owner);
	assert(reader in list.reader);
	assert(list in owner.ownerList);
	assert(list in reader.readList);
	leaveList(list,reader,false); // What we test
	assert(list.owner == owner);
	assert(!(reader in list.reader));
	assert((list in owner.ownerList));
	assert(!(list in reader.readList));
}

