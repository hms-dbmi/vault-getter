package client

import (
	"github.com/hashicorp/vault/api"
	"go.uber.org/zap"
)

// Vault client implemented
type Vault struct {
	Client *api.Client
	logger *zap.Logger
}

// Name ... Type of client
func (v *Vault) Name() string {
	return "vault"
}

// List returns list of keys
func (v *Vault) List(path string) interface{} {
	secret, err := v.Client.Logical().List(path)
	if err != nil || secret.Data == nil || secret.Data["keys"] == nil {
		v.logger.Error("Failed to list keys", zap.Errors("error", []error{err}))
		// return empty interface
		return interface{}(nil)
	}
	return secret.Data["keys"]
}

// Read returns value for path/key
func (v *Vault) Read(path string) string {
	secret, err := v.Client.Logical().Read(path)
	if err != nil || secret == nil || secret.Data["value"] == nil {
		v.logger.Warn("Failed to read secret", zap.Error(err))
		return ""
	}
	return secret.Data["value"].(string)
}
