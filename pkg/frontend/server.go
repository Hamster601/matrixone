// Copyright 2021 Matrix Origin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package frontend

import (
	"context"
	"strings"
	"sync/atomic"

	"github.com/fagongzi/goetty/v2"
	"github.com/matrixorigin/matrixone/pkg/config"
	"github.com/matrixorigin/matrixone/pkg/defines"
	"github.com/matrixorigin/matrixone/pkg/logutil"
	"github.com/matrixorigin/matrixone/pkg/queryservice"
)

// RelationName counter for the new connection
var initConnectionID uint32 = 1000

// ConnIDAllocKey is used get connection ID from HAKeeper.
var ConnIDAllocKey = "____server_conn_id"

// MOServer MatrixOne Server
type MOServer struct {
	addr  string
	uaddr string
	app   goetty.NetApplication
	rm    *RoutineManager
}

// BaseService is an interface which indicates that the instance is
// the base CN service and should implements the following methods.
type BaseService interface {
	// ID returns the ID of the service.
	ID() string
	// SQLAddress returns the SQL listen address of the service.
	SQLAddress() string
	// SessionMgr returns the session manager instance of the service.
	SessionMgr() *queryservice.SessionManager
}

func (mo *MOServer) GetRoutineManager() *RoutineManager {
	return mo.rm
}

func (mo *MOServer) Start() error {
	logutil.Infof("Server Listening on : %s ", mo.addr)
	return mo.app.Start()
}

func (mo *MOServer) Stop() error {
	return mo.app.Stop()
}

func nextConnectionID() uint32 {
	return atomic.AddUint32(&initConnectionID, 1)
}

func NewMOServer(
	ctx context.Context,
	addr string,
	pu *config.ParameterUnit,
	aicm *defines.AutoIncrCacheManager,
	baseService BaseService,
) *MOServer {
	codec := NewSqlCodec()
	rm, err := NewRoutineManager(ctx, pu, aicm)
	if err != nil {
		logutil.Panicf("start server failed with %+v", err)
	}
	rm.setBaseService(baseService)
	if baseService != nil {
		rm.setSessionMgr(baseService.SessionMgr())
	}
	// TODO asyncFlushBatch
	addresses := []string{addr}
	unixAddr := pu.SV.GetUnixSocketAddress()
	if unixAddr != "" {
		addresses = append(addresses, "unix://"+unixAddr)
	}
	app, err := goetty.NewApplicationWithListenAddress(
		addresses,
		rm.Handler,
		goetty.WithAppLogger(logutil.GetGlobalLogger()),
		goetty.WithAppSessionOptions(
			goetty.WithSessionCodec(codec),
			goetty.WithSessionLogger(logutil.GetGlobalLogger()),
			goetty.WithSessionRWBUfferSize(DefaultRpcBufferSize, DefaultRpcBufferSize),
			goetty.WithSessionAllocator(NewSessionAllocator(pu))),
		goetty.WithAppSessionAware(rm))
	if err != nil {
		logutil.Panicf("start server failed with %+v", err)
	}
	err = initVarByConfig(ctx, pu)
	if err != nil {
		logutil.Panicf("start server failed with %+v", err)
	}
	return &MOServer{
		addr:  addr,
		app:   app,
		uaddr: pu.SV.UnixSocketAddress,
		rm:    rm,
	}
}

func initVarByConfig(ctx context.Context, pu *config.ParameterUnit) error {
	var err error
	if strings.ToLower(pu.SV.SaveQueryResult) == "on" {
		err = GSysVariables.SetGlobalSysVar(ctx, "save_query_result", pu.SV.SaveQueryResult)
		if err != nil {
			return err
		}
	}

	err = GSysVariables.SetGlobalSysVar(ctx, "query_result_maxsize", pu.SV.QueryResultMaxsize)
	if err != nil {
		return err
	}

	err = GSysVariables.SetGlobalSysVar(ctx, "query_result_timeout", pu.SV.QueryResultTimeout)
	if err != nil {
		return err
	}

	err = GSysVariables.SetGlobalSysVar(ctx, "lower_case_table_names", pu.SV.LowerCaseTableNames)
	if err != nil {
		return err
	}
	return err
}
