package main

  import (
    "encoding/json"
    "fmt"
    "log"
    "time"

    "github.com/golang/protobuf/ptypes"
    "github.com/satori/go.uuid"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"

    "github.com/hyperledger/fabric-chaincode-go/pkg/cid"
  )

  type SmartContract struct {
      contractapi.Contract
  }

  type Libro struct {
    ID             string `json:"ID"`
    Nombre         string `json:"nombre"`
    Owner          string `json:"owner"`
    Estado         string `json:"estado"`
  }

  type HistoryQueryResult struct {
		Record    *Libro    `json:"record"`
		TxId      string    `json:"txId"`
		Timestamp time.Time `json:"timestamp"`
		IsDelete  bool      `json:"isDelete"`
	}

  func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    
    mspid, _:=cid.GetMSPID(ctx.GetStub())
    log.Println("Lo ha lanzado: ", mspid)
    
    myuuids := uuid.NewV4().String()
    fmt.Println("Your UUID is:", myuuids)

    myuuid2 := uuid.NewV4().String()
    fmt.Println("Your UUID2 is:", myuuid2)
    
    libros := []Libro{
      {ID: myuuids, Nombre: "El nombre del viento", Owner: mspid, Estado: "Disponible"},
      {ID: myuuid2, Nombre: "El imperio final", Owner: mspid, Estado: "Disponible"},
    }

    for _, libro := range libros {
      libroJSON, err := json.Marshal(libro)
      if err != nil {
        return err
      }
    
      err = ctx.GetStub().PutState(libro.ID, libroJSON)
      if err != nil {
        return fmt.Errorf("failed to put to world state. %v", err)
      }
    }

    return nil
  }

  func (s *SmartContract) CreateLibro(ctx contractapi.TransactionContextInterface, nombre string, owner string, estado string) error {

    myuuid := uuid.NewV4().String()
    fmt.Println("Nuevo libro UUID:", myuuid)

    libro := Libro{
      ID:          myuuid,
      Nombre:      nombre,
      Owner:       owner,
      Estado:		   estado,
    }
      
    libroJSON, err := json.Marshal(libro)
    if err != nil {
      return err
    }

    return ctx.GetStub().PutState(myuuid, libroJSON)
  }

  // ReadLibro devuelve el Libro almacenado en el World State con su última modificación
  func (s *SmartContract) ReadLibro(ctx contractapi.TransactionContextInterface, id string) (*Libro, error) {
    libroJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
      return nil, fmt.Errorf("Error al leer de Fabric: %v", err)
    }
    if libroJSON == nil {
      return nil, fmt.Errorf("El libro %s no existe", id)
    }

    var libro Libro
    err = json.Unmarshal(libroJSON, &libro)
    if err != nil {
      return nil, err
    }

    return &libro, nil
  }

  func (s *SmartContract) UpdateLibro(ctx contractapi.TransactionContextInterface, id string, nombre string, owner string, estado string) error {
    exists, err := s.LibroExists(ctx, id)
    if err != nil {
      return err
    }
    if !exists {
      return fmt.Errorf("El libro %s no existe", id)
    }

    libro := Libro{
        ID:          id,
        Nombre:      nombre,
        Owner:       owner,
        Estado:		   estado,
    }
  
    libroJSON, err := json.Marshal(libro)
  
    if err != nil {
      return err
    }

    return ctx.GetStub().PutState(id, libroJSON)
  }

  // DeleteLibro elimina a un Libro del world state
  func (s *SmartContract) DeleteLibro(ctx contractapi.TransactionContextInterface, id string) error {
    exists, err := s.LibroExists(ctx, id)
    if err != nil {
      return err
    }
    if !exists {
      return fmt.Errorf("the libro %s does not exist", id)
    }

    return ctx.GetStub().DelState(id)
  }

  // LibroExists devuelve un true si existe el ID del Libro consultado
  func (s *SmartContract) LibroExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    libroJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
      return false, fmt.Errorf("failed to read from world state: %v", err)
    }

    return libroJSON != nil, nil
  }

  // TransferLibro actualiza el dueño del Libro en el world state
  func (s *SmartContract) TransferLibro(ctx contractapi.TransactionContextInterface, id string, newOwner string) error {
    libro, err := s.ReadLibro(ctx, id)
    if err != nil {
      return err
    }

    libro.Owner = newOwner
    libroJSON, err := json.Marshal(libro)
    if err != nil {
      return err
    }

    return ctx.GetStub().PutState(id, libroJSON)
  }

  // StatusLibro actualiza el estado del Libro en el world state
  func (s *SmartContract) StatusLibro(ctx contractapi.TransactionContextInterface, id string, newStatus string) error {
    libro, err := s.ReadLibro(ctx, id)
    if err != nil {
      return err
    }

    libro.Estado = newStatus
    libroJSON, err := json.Marshal(libro)
    if err != nil {
      return err
    }

    return ctx.GetStub().PutState(id, libroJSON)
  }

  // GetAllLibros devuelve todos los Libros del world state
  func (s *SmartContract) GetAllLibros(ctx contractapi.TransactionContextInterface) ([]*Libro, error) {
    resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
    if err != nil {
      return nil, err
    }
    defer resultsIterator.Close()

    var libros []*Libro
    for resultsIterator.HasNext() {
      queryResponse, err := resultsIterator.Next()
      if err != nil {
        return nil, err
      }

      var libro Libro
      err = json.Unmarshal(queryResponse.Value, &libro)
      if err != nil {
        return nil, err
      }
      libros = append(libros, &libro)
    }

    return libros, nil
  }

  // GetLibroHistory devuelve la información histórica custodiada por el ledger
  func (t *SmartContract) GetLibroHistory(ctx contractapi.TransactionContextInterface, libroID string) ([]HistoryQueryResult, error) {
	  log.Printf("GetLibroHistory: ID %v", libroID)

	  resultsIterator, err := ctx.GetStub().GetHistoryForKey(libroID)
	  if err != nil {
  		return nil, err
  	}
  	defer resultsIterator.Close()

    var records []HistoryQueryResult
    for resultsIterator.HasNext() {
      response, err := resultsIterator.Next()
      if err != nil {
        return nil, err
      }

      var libro Libro
      if len(response.Value) > 0 {
        err = json.Unmarshal(response.Value, &libro)
        if err != nil {
          return nil, err
        }
      } else {
        libro = Libro{
          ID: libroID,
        }
      }

      timestamp, err := ptypes.Timestamp(response.Timestamp)
      if err != nil {
        return nil, err
      }

      record := HistoryQueryResult{
        TxId:      response.TxId,
        Timestamp: timestamp,
        Record:    &libro,
        IsDelete:  response.IsDelete,
      }
      records = append(records, record)
    }

    return records, nil
  }

  func main() {
    libroChaincode, err := contractapi.NewChaincode(&SmartContract{})
    if err != nil {
      log.Panicf("Error creating libro-transfer-basic chaincode: %v", err)
    }

    if err := libroChaincode.Start(); err != nil {
      log.Panicf("Error starting libro-transfer-basic chaincode: %v", err)
    }
  }
