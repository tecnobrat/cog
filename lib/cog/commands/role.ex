defmodule Cog.Commands.Role do
  use Cog.Command.GenCommand.Base, bundle: Cog.embedded_bundle
  require Cog.Commands.Helpers, as: Helpers

  alias Cog.Commands.Role.{Create, Delete, Grant, Info, List, Rename, Revoke}

  @description "Manage authorization roles"

  Helpers.usage :root, """
  #{@description}

  USAGE
    role [subcommand]

  FLAGS
    -h, --help  Display this usage info

  SUBCOMMANDS
    create     Create a new role
    delete     Delete an existing role
    grant      Grant a role to a group
    info       Get detailed information about a specific role
    list       List all roles (default)
    rename     Rename a role
    revoke     Revoke a role from a group

  """

  permission "manage_roles"
  permission "manage_groups"

  # This rule is for the default
  rule "when command is #{Cog.embedded_bundle}:role must have #{Cog.embedded_bundle}:manage_roles"

  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == create must have #{Cog.embedded_bundle}:manage_roles"
  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == delete must have #{Cog.embedded_bundle}:manage_roles"
  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == info must have #{Cog.embedded_bundle}:manage_roles"
  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == list must have #{Cog.embedded_bundle}:manage_roles"
  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == grant must have #{Cog.embedded_bundle}:manage_groups"
  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == rename must have #{Cog.embedded_bundle}:manage_roles"
  rule "when command is #{Cog.embedded_bundle}:role with arg[0] == revoke must have #{Cog.embedded_bundle}:manage_groups"

  def handle_message(req, state) do
    {subcommand, args} = Helpers.get_subcommand(req.args)

    result = case subcommand do
               "create" -> Create.create(req, args)
               "delete" -> Delete.delete(req, args)
               "grant"  -> Grant.grant(req, args)
               "info"   -> Info.info(req, args)
               "list"   -> List.list(req, args)
               "rename" -> Rename.rename(req, args)
               "revoke" -> Revoke.revoke(req, args)
               nil ->
                 if Helpers.flag?(req.options, "help") do
                   show_usage
                 else
                   List.list(req, args)
                 end
               other ->
                 {:error, {:unknown_subcommand, other}}
             end

    case result do
      {:ok, template, data} ->
         {:reply, req.reply_to, template, data, state}
      {:ok, data} ->
        {:reply, req.reply_to, data, state}
      {:error, err} ->
        {:error, req.reply_to, error(err), state}
    end
  end

  ########################################################################

  defp error({:protected_role, name}),
    do: "Cannot alter protected role #{name}"
  defp error(:wrong_type), # TODO: put this into helpers, take it out of permission.ex
    do: "Arguments must be strings"
  defp error(error),
    do: Helpers.error(error)

end
