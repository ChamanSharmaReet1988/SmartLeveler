//
//  LightTable.swift
//  RemoteLight
//
//  Copyright © 2018 Chaman. All rights reserved.
//

import UIKit
import SQLite3

class ReadingTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    class func createReadingTable()
    {
        let sqlLightTable = "CREATE TABLE ReadingTable(localId INTEGER PRIMARY KEY AUTOINCREMENT, height TEXT, evPercentage TEXT, dateTime TEXT, comment TEXT, heightUnit TEXT , fraction TEXT)"
        if sqlite3_exec(databaseConnection, sqlLightTable, nil, nil, nil) != SQLITE_OK
        {
            print("Error in creating ReadingTable")
        }
    }
    
    func saveReading(readingModel :ReadingModel)
    {
        statement = nil
        let query = "INSERT into ReadingTable (height, evPercentage, dateTime, comment, heightUnit, fraction) VALUES (?, ?, ?, ?, ?, ?)"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK
        {
            sqlite3_bind_text(statement, 1, readingModel.height! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, readingModel.evPercentage! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, readingModel.dateTime! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, readingModel.comment! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, readingModel.heightUnit! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, readingModel.fraction! , -1, SQLITE_TRANSIENT)

            if SQLITE_DONE != sqlite3_step(statement)
            {
                print(sqlite3_errmsg(statement))
            }
            sqlite3_finalize(statement)
        }
    }
    
    func updateReading(readingModel :ReadingModel)
    {
        statement = nil
        print(readingModel.comment!)
        let query = "UPDATE ReadingTable set height = ?, evPercentage = ?, dateTime = ?, comment = ?, heightUnit = ?, fraction = ? WHERE localId = \(readingModel.localId!)"
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, readingModel.height! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, readingModel.evPercentage! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, readingModel.dateTime! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, readingModel.comment! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, readingModel.heightUnit! , -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, readingModel.fraction! , -1, SQLITE_TRANSIENT)

            if SQLITE_DONE != sqlite3_step(statement) {
                print(sqlite3_errmsg(statement))
            }
            sqlite3_finalize(statement)
        }
    }
    
    func getReading(_ localId: String) -> ReadingModel {
        let querySQL = "select * from ReadingTable WHERE localId = ?"
        let readingModel = ReadingModel()
        readingModel.localId = localId
        if sqlite3_prepare_v2(Database.databaseConnection, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, localId , -1, SQLITE_TRANSIENT)
            while sqlite3_step(statement) == SQLITE_ROW
            {
                readingModel.height = String(cString: sqlite3_column_text(statement, 1))
                readingModel.evPercentage = String(cString: sqlite3_column_text(statement, 2))
                readingModel.dateTime = String(cString: sqlite3_column_text(statement, 3))
                readingModel.comment = String(cString: sqlite3_column_text(statement, 4))
                readingModel.heightUnit = String(cString: sqlite3_column_text(statement, 5))
                readingModel.fraction = String(cString: sqlite3_column_text(statement, 6))

            }
        }
        sqlite3_finalize(statement)
        return readingModel
    }
    
    func getReadings() -> [ReadingModel] {
        let querySQL = "select * from ReadingTable"
        var readings = [ReadingModel]()
        if sqlite3_prepare_v2(Database.databaseConnection, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let readingModel = ReadingModel()
                readingModel.localId = String(cString: sqlite3_column_text(statement, 0))
                readingModel.height = String(cString: sqlite3_column_text(statement, 1))
                readingModel.evPercentage = String(cString: sqlite3_column_text(statement, 2))
                readingModel.dateTime = String(cString: sqlite3_column_text(statement, 3))
                readingModel.comment = String(cString: sqlite3_column_text(statement, 4))
                readingModel.heightUnit = String(cString: sqlite3_column_text(statement, 5))
                readingModel.fraction = String(cString: sqlite3_column_text(statement, 6))
                readings.append(readingModel)
            }
        }
        sqlite3_finalize(statement)
        return readings
    }
    
    func deleteTableByLocalId(localId: String) {
        let querySQL = "delete from ReadingTable WHERE localId = ?"
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(Database.databaseConnection, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, localId , -1, SQLITE_TRANSIENT)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

}
