// Copyright (c) 2016 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

public extension String {
    public func unescapeEntities(entities: [String:String] = EntitySet.XMLSpecialC0ControlAndBasicLatinEntities, longestName: Int = 8) -> String {
        enum State {
            case Looking
            case Started
            case Extract
        }
        let ampersand = UnicodeScalar(0x0026)
        let semicolon = UnicodeScalar(0x003B)
        let scalars = self.unicodeScalars
        var state = State.Looking
        var unescaped = String()
        unescaped.reserveCapacity(scalars.count)
        var name = String()
        name.reserveCapacity(longestName)
        
        for scalar in scalars {
            switch state {
            case .Looking:
                if scalar == ampersand {
                    state = .Started
                } else {
                    unescaped.append(scalar)
                }
            case .Started:
                if scalar == ampersand {
                    unescaped.append(ampersand)
                } else if scalar == semicolon {
                    unescaped.append(ampersand)
                    unescaped.append(semicolon)
                    state = .Looking
                } else {
                    name.append(scalar)
                    state = .Extract
                }
            case .Extract:
                if scalar == ampersand {
                    unescaped.append(ampersand)
                    unescaped.appendContentsOf(name)
                    name.removeAll(keepCapacity: true)
                    state = .Started
                } else if scalar == semicolon {
                    if let entity = entities[name] {
                        unescaped.appendContentsOf(entity)
                    } else {
                        unescaped.append(ampersand)
                        unescaped.appendContentsOf(name)
                        unescaped.append(semicolon)
                    }
                    name.removeAll(keepCapacity: true)
                    state = .Looking
                } else if name.unicodeScalars.count >= longestName {
                    unescaped.append(ampersand)
                    unescaped.appendContentsOf(name)
                    unescaped.append(scalar)
                    name.removeAll(keepCapacity: true)
                    state = .Looking
                } else {
                    name.append(scalar)
                }
            }
        }
        
        switch state {
        case .Looking:
            break
        case .Started:
            unescaped.append(ampersand)
        case .Extract:
            unescaped.append(ampersand)
            unescaped.appendContentsOf(name)
        }
        
        return unescaped
    }
}
