package main

  import (
    "encoding/json"
    "fmt"
    "log"
    "time"

    "github.com/golang/protobuf/ptypes"
    "github.com/satori/go.uuid"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"

    "github.com/hyperledger/fabric-chaincode-go/shim"
    "github.com/hyperledger/fabric-chaincode-go/pkg/cid"
    "strings"
  )

  type SmartContract struct {
      contractapi.Contract
  }

  type Usuario struct {
    ID             string `json:"ID"`
    Libro          string `json:"libro"`
  }

  type HistoryQueryResult struct {
		Record    *Libro    `json:"record"`
		TxId      string    `json:"txId"`
		Timestamp time.Time `json:"timestamp"`
		IsDelete  bool      `json:"isDelete"`
  }

  func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    
   )
    
    usuarios := []Usuario{
      {ID: 1, Libro: ""},
      {ID: 2, Libro: ""},
    }

    for _, usuario := range usuarios {
      usuarioJSON, err := json.Marshal(usuario)
      if err != nil {
        return err
      }
    
      err = ctx.GetStub().PutState(usuario.ID, usuarioJSON)
      if err != nil {
        return fmt.Errorf("failed to put to world state. %v", err)
      }
    }

    return nil
  }

  func (s *SmartContract) CreateUser(ctx contractapi.TransactionContextInterface, id string,) error {
	  exists, err := s.UserExists(ctx, id)
    if err != nil {
      return err
    }
    if exists {
      return fmt.Errorf("El usuario %s existe en la blockchain", id)
    }
    usuario := Usuario{
      ID:    id,
      Libro: ""
    }
      
    usuarioJSON, err := json.Marshal(usuario)
    if err != nil {
      return err
    }

    return ctx.GetStub().PutState(id, usuarioJSON)
  }

  // ReadUser devuelve el User almacenado en el World State con su última modificación
  func (s *SmartContract) ReadUser(ctx contractapi.TransactionContextInterface, id string) (*Usuario, error) {
    exists, err := s.UserExists(ctx, id)
    if err != nil {
      return err
    }
    if !exists {
      return fmt.Errorf("El usuario %s existe en la blockchain", id)
    }

    var user Usuario
    err = json.Unmarshal(userJSON, &user)
    if err != nil {
      return nil, err
    }

    return &user, nil
  }

  // DeleteUser elimina a un User del world state
  func (s *SmartContract) DeleteUser(ctx contractapi.TransactionContextInterface, id string) error {
    exists, err := s.UserExists(ctx, id)
    if err != nil {
      return err
    }
    if !exists {
      return fmt.Errorf("El user %s no existe", id)
    }

    return ctx.GetStub().DelState(id)
  }

  // UserExists devuelve un true si existe el ID del User consultado
  func (s *SmartContract) UserExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    userJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
      return false, fmt.Errorf("failed to read from world state: %v", err)
    }

    return userJSON != nil, nil
  }

  // GetAllUsers devuelve todos los Users del world state
  func (s *SmartContract) GetAllUsers(ctx contractapi.TransactionContextInterface) ([]*Usuario, error) {
    resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
    if err != nil {
      return nil, err
    }
    defer resultsIterator.Close()

    var usuarios []*Usuario
    for resultsIterator.HasNext() {
      queryResponse, err := resultsIterator.Next()
      if err != nil {
        return nil, err
      }

      var usuario Usuario
      err = json.Unmarshal(queryResponse.Value, &usuario)
      if err != nil {
        return nil, err
      }
      usuarios = append(usuarios, &usuario)
    }

    return usuarios, nil
  }

  // GetUserHistory devuelve la información histórica custodiada por el ledger
  func (t *SmartContract) GetUserHistory(ctx contractapi.TransactionContextInterface, userID string) ([]HistoryQueryResult, error) {
	  log.Printf("GetUserHistory: ID %v", userID)

	  resultsIterator, err := ctx.GetStub().GetHistoryForKey(userID)
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

      var usuario Usuario
      if len(response.Value) > 0 {
        err = json.Unmarshal(response.Value, &usuario)
        if err != nil {
          return nil, err
        }
      } else {
        usuario = Usuario{
          ID: userID,
        }
      }

      timestamp, err := ptypes.Timestamp(response.Timestamp)
      if err != nil {
        return nil, err
      }

      record := HistoryQueryResult{
        TxId:      response.TxId,
        Timestamp: timestamp,
        Record:    &usuario,
        IsDelete:  response.IsDelete,
      }
      records = append(records, record)
    }

    return records, nil
  }

  func (s *SmartContract) HaveBook(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    user, err := s.ReadUser(ctx, id)
    if err != nil {
      return err
    }
   
    return user.Libro != ""
    
  }

  func (s *SmartContract) UpdateBook(ctx contractapi.TransactionContextInterface, userID string, bookID string) error {
    user, err := s.ReadUser(ctx, userID)
    if  err != nil {
      return err
    }

    user.Libro = bookID
    userJSON, err := json.Marshal(user)
    if err != nil {
      return err
    }

    return ctx.GetStub().PutState(userID, userJSON)
  }


  func main() {
    userChaincode, err := contractapi.NewChaincode(&SmartContract{})
    if err != nil {
      log.Panicf("Error creating usuario-transfer-basic chaincode: %v", err)
    }

    if err := userChaincode.Start(); err != nil {
      log.Panicf("Error starting usuario-transfer-basic chaincode: %v", err)
    }
  }

