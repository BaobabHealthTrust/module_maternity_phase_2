INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Ante-Natal Ward", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Ante-Natal Ward" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Bwaila Maternity Unit", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Bwaila Maternity Unit" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Labour Ward", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Labour Ward" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Post-Natal Ward", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Post-Natal Ward" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Gynaecology Ward", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Gynaecology Ward" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Post-Natal Ward (Low Risk)", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Post-Natal Ward (Low Risk)" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Post-Natal Ward (High Risk)", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Post-Natal Ward (High Risk)" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Kamuzu Central Hospital", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Kamuzu Central Hospital" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Ethel Mutharika Maternity Wing", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Ethel Mutharika Maternity Wing" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Theater", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Theater" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "High Dependency Unit (HDU)", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "High Dependency Unit (HDU)" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Private Obstetric and Gynaecology", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Private Obstetric and Gynaecology" LIMIT 1);

INSERT INTO location (name, description, creator, date_created, retired, uuid)
	SELECT "Registration", "(ID=700)", 1, now(), 0, UUID()
    FROM dual
	WHERE NOT EXISTS (SELECT name FROM location WHERE name = "Registration" LIMIT 1);




