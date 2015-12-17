# Jasoom 1.0.0

#### An easy to use, type safe, Swift wrapper for NSJSONSerialization

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Parsing JSON

    do {
        let json = try JSON.parseData(data)
		
		if json["name"].isUndefined {
			throw .MissingName
		}
		
        if json["info"]["age"].isUndefined {
			throw .MissingAge
		}
		
		let model = MyModel(
			name: json["name"].stringValue!
			age: json["info"]["age"].intValue!
			married: json["status"]["married"].boolValue ?? false
			firstCar: json["cars"][0].stringValue ?? ""
		)
	}
    catch {
		// Handle error
    }

## Generating JSON

	var object = JSON.object()
	object["name"] = .String("Bob Smith")
	object["info"] = JSON.object()
	object["info"]["age"] = .Number(10)
	object["status"] = JSON.object()
	object["status"]["married"] = .Number(true)
	object["cars"] = JSON.array()
	object["cars"].append(.String("Ford Mustang"))
    
	do {
		let data = try object.generateData()
	}
	catch {
		// Handle error
	}

## Contact

[Justin Kolb](mailto:justin.kolb@franticapparatus.net)  
[@nabobnick](https://twitter.com/nabobnick)

## License

Jasoom is available under the MIT license. See the LICENSE file for more info.
