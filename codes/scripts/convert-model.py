import torch

# Make 2xPSNR
state=torch.load("4x_RRDB_PSNR.pth")
state2=torch.load("2xESRGAN.pth")
state["model.7.weight"]=state["model.10.weight"]
state["model.7.bias"]=state["model.10.bias"]
state["model.5.weight"]=state2["model.5.weight"]
state["model.5.bias"]=state2["model.5.bias"]
state.pop("model.6.weight", None)
state.pop("model.6.bias", None)
state.pop("model.8.weight", None)
state.pop("model.8.bias", None)
state.pop("model.10.weight", None)
state.pop("model.10.bias", None)
torch.save(state, "2x_RRDB_PSNR-bad.pth")

# Make 1xPSNR
state2=torch.load("1xESRGAN.pth")
state["model.4.weight"]=state["model.7.weight"]
state["model.4.bias"]=state["model.7.bias"]
state["model.2.weight"]=state2["model.2.weight"]
state["model.2.bias"]=state2["model.2.bias"]
state.pop("model.3.weight", None)
state.pop("model.3.bias", None)
state.pop("model.5.weight", None)
state.pop("model.5.bias", None)
state.pop("model.7.weight", None)
state.pop("model.7.bias", None)
torch.save(state, "1x_RRDB_PSNR-bad.pth")

# Make 8xPSNR
state=torch.load("4x_RRDB_PSNR.pth")
state["model.13.weight"]=state["model.10.weight"]
state["model.13.bias"]=state["model.10.bias"]
state["model.11.weight"]=state["model.8.weight"]
state["model.11.bias"]=state["model.8.bias"]
state["model.9.weight"]=state["model.6.weight"]
state["model.9.bias"]=state["model.6.bias"]
state.pop("model.8.weight", None)
state.pop("model.8.bias", None)
state.pop("model.10.weight", None)
state.pop("model.10.bias", None)
torch.save(state, "8x_RRDB_PSNR-bad.pth")

# Make 16xPSNR
state["model.16.weight"]=state["model.13.weight"]
state["model.16.bias"]=state["model.13.bias"]
state["model.14.weight"]=state["model.11.weight"]
state["model.14.bias"]=state["model.11.bias"]
state["model.12.weight"]=state["model.6.weight"]
state["model.12.bias"]=state["model.6.bias"]
state.pop("model.11.weight", None)
state.pop("model.11.bias", None)
state.pop("model.13.weight", None)
state.pop("model.13.bias", None)
torch.save(state, "16x_RRDB_PSNR-bad.pth")
